#!/usr/bin/env bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is dual-licensed under either the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree or the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree. You may select, at your option, one of the
# above-listed licenses.

# usage: dupe_features.sh [<target without std>...]
#
# Lints and tests `dupe` with each of its feature sets by itself, from the root
# of the cargo workspace. `dupe` is `no_std` without its default features, and
# a build of the workspace turns all of them on.
#
# The `no_std` feature sets are also linted for each target given, which the
# toolchain must have installed. With a target that has no `std`, such as
# `thumbv7em-none-eabi`, that fails if `dupe` or one of its dependencies still
# links `std`; the host has one to link.

set -euo pipefail

for features in "" alloc derive alloc,derive std; do
  echo "::group::dupe features [$features]"
  cargo clippy --locked -p dupe --no-default-features --features="$features" --all-targets -- --deny=warnings
  cargo test --locked -p dupe --no-default-features --features="$features"
  echo "::endgroup::"
done

for target in "$@"; do
  for features in "" alloc derive alloc,derive; do
    echo "::group::dupe features [$features] for $target"
    cargo clippy --locked -p dupe --no-default-features --features="$features" --target="$target" -- --deny=warnings
    echo "::endgroup::"
  done
done
