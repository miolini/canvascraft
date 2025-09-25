use rustler::{Encoder, Env, NifResult, Term};

#[rustler::nif]
fn skia_hello<'a>(env: Env<'a>) -> NifResult<Term<'a>> {
    Ok("skia_unavailable".encode(env))
}

rustler::init!("Elixir.CanvasCraft.Native.Skia", [skia_hello]);
