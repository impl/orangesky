extern crate gcc;

use std::env;
use std::fs;
use std::path;

fn main() {
    let target = env::var("TARGET").unwrap();
    let target_vec: Vec<&str> = target.splitn(3, "-").collect();

    if target_vec.len() != 3 {
        panic!("unsupported target: {}", target);
    }

    let arch = target_vec[0];
    let vendor = target_vec[1];
    let sys = target_vec[2];

    let arch_path = path::PathBuf::from("src/arch").join(arch);
    if fs::metadata(&arch_path).is_err() {
        panic!("unsupported architecture: {}", arch);
    }

    let mut config = gcc::Config::new();
    for file_name in ["start.S"].iter() {
        let file_path = arch_path.join(file_name);
        config.file(file_path.as_os_str());
    }
    config.compile("libstart.a");
}
