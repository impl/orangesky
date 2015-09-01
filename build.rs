extern crate gcc;

use std::env;
use std::fs;
use std::path;

fn main() {
    let target = env::var("TARGET").unwrap();

    let target_path = path::PathBuf::from("src/target").join(&target);
    if fs::metadata(&target_path).is_err() {
        panic!("unsupported target: {}", target);
    }

    let mut config = gcc::Config::new();
    for file_name in ["start.S"].iter() {
        let file_path = target_path.join(file_name);
        config.file(file_path.as_os_str());
    }
    config.compile("libstart.a");
}
