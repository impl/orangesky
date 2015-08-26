extern crate gcc;

use std::env;
use std::fs;
use std::path;

fn main() {
    let target = env::var("TARGET").unwrap();

    let arch_path = path::PathBuf::from("src/arch").join(&target);
    if fs::metadata(&arch_path).is_err() {
        panic!("unsupported target: {}", target);
    }

    let mut config = gcc::Config::new();
    for file_name in ["start.S"].iter() {
        let file_path = arch_path.join(file_name);
        config.file(file_path.as_os_str());
    }
    config.compile("libstart.a");
}
