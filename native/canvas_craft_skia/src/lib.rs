use rustler::{types::binary::OwnedBinary, Encoder, Env, NifResult, ResourceArc, Term};
use std::io::Cursor;
use std::sync::Mutex;

struct Radial {
    cx: f32,
    cy: f32,
    r: f32,
    c0: [u8; 4],
    c1: [u8; 4],
}

struct SurfaceInner {
    w: usize,
    h: usize,
    buf: Vec<u8>, // RGBA8
    shader: Option<Radial>,
    aa_samples: u8,
    font: Option<rusttype::Font<'static>>,
    font_scale: f32,
}

struct Surface(Mutex<SurfaceInner>);

#[rustler::nif]
fn skia_hello<'a>(env: Env<'a>) -> NifResult<Term<'a>> {
    Ok("skia_minimal".encode(env))
}

#[rustler::nif]
fn new_surface<'a>(env: Env<'a>, w: i64, h: i64, _opts: Term<'a>) -> NifResult<ResourceArc<Surface>> {
    let _ = env;
    let w = w.max(1) as usize;
    let h = h.max(1) as usize;
    let buf = vec![0u8; w * h * 4];
    Ok(ResourceArc::new(Surface(Mutex::new(SurfaceInner {
        w,
        h,
        buf,
        shader: None,
        aa_samples: 4,
        font: None,
        font_scale: 18.0,
    }))))
}

#[rustler::nif]
fn set_antialias<'a>(env: Env<'a>, surf: ResourceArc<Surface>, aa: Term<'a>) -> NifResult<Term<'a>> {
    let mut guard = surf.0.lock().unwrap();
    let samples: u8 = if let Ok(b) = aa.decode::<bool>() { if b { 4 } else { 1 } } else if let Ok(n) = aa.decode::<i64>() { match n { 8 => 8, 4 => 4, 1 => 1, _ => 4 } } else { 4 };
    guard.aa_samples = samples;
    Ok(rustler::types::atom::ok().encode(env))
}

#[rustler::nif]
fn get_rgba_buffer<'a>(env: Env<'a>, surf: ResourceArc<Surface>) -> NifResult<Term<'a>> {
    let guard = surf.0.lock().unwrap();
    let stride = (guard.w * 4) as i64;
    let mut bin = OwnedBinary::new(guard.buf.len()).ok_or(rustler::Error::Term(Box::new("alloc_failed")))?;
    bin.as_mut_slice().copy_from_slice(&guard.buf);
    let term = (
        guard.w as i64,
        guard.h as i64,
        stride,
        bin.release(env),
    )
        .encode(env);
    Ok(term)
}

#[rustler::nif]
fn encode_webp<'a>(env: Env<'a>, surf: ResourceArc<Surface>, _opts: Term<'a>) -> NifResult<Term<'a>> {
    let guard = surf.0.lock().unwrap();
    let mut out = Vec::new();
    {
        let mut cursor = Cursor::new(&mut out);
        let mut encoder = image::codecs::webp::WebPEncoder::new_lossless(&mut cursor);
        encoder
            .encode(&guard.buf, guard.w as u32, guard.h as u32, image::ExtendedColorType::Rgba8)
            .map_err(|_| rustler::Error::Term(Box::new("encode_failed")))?;
    }
    drop(guard);
    let mut bin = OwnedBinary::new(out.len()).ok_or(rustler::Error::Term(Box::new("alloc_failed")))?;
    bin.as_mut_slice().copy_from_slice(&out);
    Ok((rustler::types::atom::ok(), bin.release(env)).encode(env))
}

#[rustler::nif]
fn set_radial_gradient<'a>(env: Env<'a>, surf: ResourceArc<Surface>, cx: f64, cy: f64, r: f64, stops: Term<'a>) -> NifResult<Term<'a>> {
    // Expect stops = list of {offset, {r,g,b,a}} and use first and last colors
    let mut c0 = [0u8; 4];
    let mut c1 = [0u8; 4];
    let list: Vec<Term> = stops.decode()?;
    if let Some(first) = list.first() {
        if let Ok((_, rgba)) = first.decode::<(f64, (u8, u8, u8, u8))>() {
            c0 = [rgba.0, rgba.1, rgba.2, rgba.3];
        }
    }
    if let Some(last) = list.last() {
        if let Ok((_, rgba)) = last.decode::<(f64, (u8, u8, u8, u8))>() {
            c1 = [rgba.0, rgba.1, rgba.2, rgba.3];
        }
    }
    let grad = Radial { cx: cx as f32, cy: cy as f32, r: r as f32, c0, c1 };
    let mut guard = surf.0.lock().unwrap();
    guard.shader = Some(grad);
    Ok(rustler::types::atom::ok().encode(env))
}

#[rustler::nif]
fn draw_oval<'a>(env: Env<'a>, surf: ResourceArc<Surface>, cx: f64, cy: f64, rx: f64, ry: f64) -> NifResult<Term<'a>> {
    let mut guard = surf.0.lock().unwrap();
    let shader = match &guard.shader {
        Some(s) => Radial { cx: s.cx, cy: s.cy, r: s.r, c0: s.c0, c1: s.c1 },
        None => Radial { cx: cx as f32, cy: cy as f32, r: rx.min(ry) as f32, c0: [0,0,0,255], c1: [0,0,0,0] },
    };

    let cx = cx as f32;
    let cy = cy as f32;
    let rx = rx.abs() as f32;
    let ry = ry.abs() as f32;

    let min_x = ((cx - rx).floor() as i32).max(0) as usize;
    let max_x = ((cx + rx).ceil() as usize).min(guard.w.saturating_sub(1));
    let min_y = ((cy - ry).floor() as i32).max(0) as usize;
    let max_y = ((cy + ry).ceil() as usize).min(guard.h.saturating_sub(1));

    // 4-sample MSAA offsets inside the pixel
    let samples = match guard.aa_samples { 8 => vec![(0.125,0.125),(0.375,0.125),(0.625,0.125),(0.875,0.125),(0.25,0.375),(0.5,0.5),(0.75,0.625),(0.875,0.875)], 1 => vec![(0.5,0.5)], _ => vec![(0.25,0.25),(0.75,0.25),(0.25,0.75),(0.75,0.75)] };

    for y in min_y..=max_y {
        for x in min_x..=max_x {
            // Coverage estimation
            let mut covered = 0usize;
            for (ox, oy) in &samples {
                let nx = ((x as f32 + *ox) - cx) / rx;
                let ny = ((y as f32 + *oy) - cy) / ry;
                if nx * nx + ny * ny <= 1.0 { covered += 1; }
            }
            if covered == 0 { continue; }
            let coverage = (covered as f32) / (samples.len() as f32);

            // Gradient at pixel center
            let dxg = x as f32 + 0.5 - shader.cx;
            let dyg = y as f32 + 0.5 - shader.cy;
            let dist = (dxg * dxg + dyg * dyg).sqrt();
            let t = (dist / shader.r).min(1.0).max(0.0);
            let inv = 1.0 - t;
            let r = (shader.c0[0] as f32 * inv + shader.c1[0] as f32 * t) as u8;
            let g = (shader.c0[1] as f32 * inv + shader.c1[1] as f32 * t) as u8;
            let b = (shader.c0[2] as f32 * inv + shader.c1[2] as f32 * t) as u8;
            let a_base = (shader.c0[3] as f32 * inv + shader.c1[3] as f32 * t) as f32;
            let a = (a_base * coverage).clamp(0.0, 255.0);

            let idx = (y * guard.w + x) * 4;
            // source-over blend
            let da = guard.buf[idx + 3] as f32 / 255.0;
            let sa = a / 255.0;
            let out_a = sa + da * (1.0 - sa);
            let blend = |src: u8, dst: u8| -> u8 {
                let s = src as f32 / 255.0;
                let d = dst as f32 / 255.0;
                if out_a == 0.0 { 0 } else { (((s * sa + d * da * (1.0 - sa)) / out_a) * 255.0).round() as u8 }
            };
            let dr = guard.buf[idx];
            let dg = guard.buf[idx + 1];
            let db = guard.buf[idx + 2];
            guard.buf[idx] = blend(r, dr);
            guard.buf[idx + 1] = blend(g, dg);
            guard.buf[idx + 2] = blend(b, db);
            guard.buf[idx + 3] = (out_a * 255.0).round() as u8;
        }
    }

    Ok(rustler::types::atom::ok().encode(env))
}

#[inline]
fn blend_src_over(dst: &mut [u8], idx: usize, r: u8, g: u8, b: u8, a: f32) {
    let da = dst[idx + 3] as f32 / 255.0;
    let sa = a;
    let out_a = sa + da * (1.0 - sa);
    let blend = |src: u8, dstc: u8| -> u8 {
        let s = src as f32 / 255.0;
        let d = dstc as f32 / 255.0;
        if out_a == 0.0 { 0 } else { (((s * sa + d * da * (1.0 - sa)) / out_a) * 255.0).round() as u8 }
    };
    let dr = dst[idx];
    let dg = dst[idx + 1];
    let db = dst[idx + 2];
    dst[idx] = blend(r, dr);
    dst[idx + 1] = blend(g, dg);
    dst[idx + 2] = blend(b, db);
    dst[idx + 3] = (out_a * 255.0).round() as u8;
}

#[rustler::nif]
fn clear<'a>(env: Env<'a>, surf: ResourceArc<Surface>, r: u8, g: u8, b: u8, a: u8) -> NifResult<Term<'a>> {
    let mut guard = surf.0.lock().unwrap();
    for px in guard.buf.chunks_exact_mut(4) {
        px[0] = r; px[1] = g; px[2] = b; px[3] = a;
    }
    Ok(rustler::types::atom::ok().encode(env))
}

#[rustler::nif]
fn fill_rect<'a>(env: Env<'a>, surf: ResourceArc<Surface>, x: i64, y: i64, w: i64, h: i64, r: u8, g: u8, b: u8, a: u8) -> NifResult<Term<'a>> {
    if w <= 0 || h <= 0 { return Ok(rustler::types::atom::ok().encode(env)); }
    let mut guard = surf.0.lock().unwrap();
    let x0 = x.max(0) as usize;
    let y0 = y.max(0) as usize;
    let x1 = ((x + w) as usize).min(guard.w);
    let y1 = ((y + h) as usize).min(guard.h);
    let sa = a as f32 / 255.0;
    for yy in y0..y1 {
        for xx in x0..x1 {
            let idx = (yy * guard.w + xx) * 4;
            blend_src_over(&mut guard.buf, idx, r, g, b, sa);
        }
    }
    Ok(rustler::types::atom::ok().encode(env))
}

#[rustler::nif]
fn fill_circle<'a>(env: Env<'a>, surf: ResourceArc<Surface>, cx: f64, cy: f64, radius: f64, r: u8, g: u8, b: u8, a: u8) -> NifResult<Term<'a>> {
    if radius <= 0.0 { return Ok(rustler::types::atom::ok().encode(env)); }
    let mut guard = surf.0.lock().unwrap();
    let cx = cx as f32; let cy = cy as f32; let r2 = (radius as f32) * (radius as f32);
    let x0 = ((cx - radius as f32).floor() as i32).max(0) as usize;
    let y0 = ((cy - radius as f32).floor() as i32).max(0) as usize;
    let x1 = ((cx + radius as f32).ceil() as usize).min(guard.w);
    let y1 = ((cy + radius as f32).ceil() as usize).min(guard.h);

    // Respect AA sample count (1,4,8). Same pattern as draw_oval.
    let samples: &[(f32, f32)] = match guard.aa_samples {
        8 => &[(0.125,0.125),(0.375,0.125),(0.625,0.125),(0.875,0.125),(0.25,0.375),(0.5,0.5),(0.75,0.625),(0.875,0.875)],
        1 => &[(0.5,0.5)],
        _ => &[(0.25,0.25),(0.75,0.25),(0.25,0.75),(0.75,0.75)],
    };

    for yy in y0..y1 {
        for xx in x0..x1 {
            // MSAA coverage estimation
            let mut covered = 0usize;
            for (ox, oy) in samples {
                let dx = (xx as f32 + *ox) - cx;
                let dy = (yy as f32 + *oy) - cy;
                if dx*dx + dy*dy <= r2 { covered += 1; }
            }
            if covered == 0 { continue; }
            let coverage = (covered as f32) / (samples.len() as f32);
            let idx = (yy * guard.w + xx) * 4;
            let sa = (a as f32 / 255.0) * coverage;
            blend_src_over(&mut guard.buf, idx, r, g, b, sa);
        }
    }
    Ok(rustler::types::atom::ok().encode(env))
}

#[rustler::nif]
fn font_load_path<'a>(env: Env<'a>, surf: ResourceArc<Surface>, path: String) -> NifResult<Term<'a>> {
    let data = std::fs::read(path).map_err(|_| rustler::Error::Term(Box::new("font_read_failed")))?;
    let font = rusttype::Font::try_from_vec(data).ok_or(rustler::Error::Term(Box::new("font_bad")))?;
    let mut guard = surf.0.lock().unwrap();
    guard.font = Some(font);
    Ok(rustler::types::atom::ok().encode(env))
}

#[rustler::nif]
fn font_set_size<'a>(env: Env<'a>, surf: ResourceArc<Surface>, size: f64) -> NifResult<Term<'a>> {
    let mut guard = surf.0.lock().unwrap();
    guard.font_scale = size as f32;
    Ok(rustler::types::atom::ok().encode(env))
}

#[rustler::nif]
fn draw_text<'a>(env: Env<'a>, surf: ResourceArc<Surface>, x: f64, y: f64, text: String, r: u8, g: u8, b: u8, a: u8) -> NifResult<Term<'a>> {
    let mut guard = surf.0.lock().unwrap();
    let font = match &guard.font { Some(f) => f.clone(), None => return Ok(rustler::types::atom::ok().encode(env)) };
    let scale = rusttype::Scale::uniform(guard.font_scale);
    let v_metrics = font.v_metrics(scale);
    let baseline = y as f32 + v_metrics.ascent;
    let start = rusttype::point(x as f32, baseline);
    let glyphs: Vec<_> = font.layout(&text, scale, start).collect();
    let sa = a as f32 / 255.0;
    for gph in glyphs {
        if let Some(bb) = gph.pixel_bounding_box() {
            gph.draw(|gx, gy, v| {
                if v <= 0.0 { return; }
                let px = bb.min.x + gx as i32;
                let py = bb.min.y + gy as i32;
                if px < 0 || py < 0 { return; }
                let (pxu, pyu) = (px as usize, py as usize);
                if pxu >= guard.w || pyu >= guard.h { return; }
                let idx = (pyu * guard.w + pxu) * 4;
                let alpha = (v as f32) * sa;
                blend_src_over(&mut guard.buf, idx, r, g, b, alpha);
            });
        }
    }
    Ok(rustler::types::atom::ok().encode(env))
}

fn load(env: Env, _info: Term) -> bool {
    rustler::resource!(Surface, env);
    true
}

rustler::init!(
    "Elixir.CanvasCraft.Native.Skia",
    [skia_hello, new_surface, get_rgba_buffer, encode_webp, set_radial_gradient, draw_oval, set_antialias, clear, fill_rect, fill_circle, font_load_path, font_set_size, draw_text],
    load = load
);
