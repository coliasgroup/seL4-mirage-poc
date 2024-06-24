#
# Copyright 2023, Colias Group, LLC
#
# SPDX-License-Identifier: BSD-2-Clause
#

{ mk, localCrates, versions }:

mk {
  package.name = "sp804-driver";
  dependencies = {
    inherit (localCrates)
      sel4-microkit-message
      sel4-microkit-driver-adapters
      sel4-driver-interfaces
      sel4-sp804-driver
    ;
    sel4-microkit = localCrates.sel4-microkit // { default-features = false; };
  };
}
