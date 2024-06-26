{ lib, stdenv, splicePackages
, this
, buildCratesInLayers
, vendorLockfile
}:

self: with self;

let
  overrideLibc = libc: stdenv.override (drv: {
    cc = drv.cc.override {
      inherit libc;
      bintools = stdenv.cc.bintools.override {
        inherit libc;
      };
    };
    allowedRequisites = null;
  });

in {
  defaultRustEnvironment = this.defaultRustEnvironment.override {
    vendoredSuperLockfile = vendorLockfile { lockfile = ../../Cargo.lock; };
  };

  buildCratesInLayers = this.buildCratesInLayers.override {
    inherit defaultRustEnvironment;
  };

  crates = callPackage ./crates.nix {};

  musl = callPackage ./musl.nix {};

  muslForMirage = callPackage ./musl-for-mirage.nix {};

  stdenvMirage = overrideLibc muslForMirage;

  ocamlScope =
    let
      superOtherSplices = otherSplices;
    in
    let
      otherSplices = with superOtherSplices; {
        selfBuildBuild = selfBuildBuild.ocamlScope;
        selfBuildHost = selfBuildHost.ocamlScope;
        selfBuildTarget = selfBuildTarget.ocamlScope;
        selfHostHost = selfHostHost.ocamlScope;
        selfTargetTarget = selfTargetTarget.ocamlScope or {};
      };
    in
      lib.makeScopeWithSplicing
        splicePackages
        newScope
        otherSplices
        (_: {})
        (_: {})
        (self: callPackage ./ocaml {} self // {
          __dontMashWhenSplicingChildren = true;
          inherit superOtherSplices otherSplices; # for convenience
        })
      ;

  inherit (ocamlScope) icecap-ocaml-runtime;
}
