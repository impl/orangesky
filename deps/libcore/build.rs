#![feature(rustc_private)]

extern crate rustc_driver;
extern crate git2;

use git2::{Oid, ObjectType, ResetType, Repository};
use git2::build::CheckoutBuilder;

fn main() {
    // The commit to switch to for rustc compatibility.
    let oid = Oid::from_str(rustc_driver::commit_hash_str().unwrap()).unwrap();

    // Open repo.
    let repo = Repository::open("../../external/rust").unwrap();

    // Hard reset to requested commit.
    let object = repo.find_object(oid, Some(ObjectType::Commit)).unwrap();
    repo.reset(&object, ResetType::Hard, Some(CheckoutBuilder::new().force().remove_untracked(true))).unwrap();
}
