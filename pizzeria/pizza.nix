{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.pizza;
in
{
  options.pizza = {
    toppings = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "pepperoni" "mushroom" ];
      description = "원하는 토핑 목록";
    };

    excludedToppings = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "onion" "olive" ];
      description = "빼고 싶은 토핑 목록";
    };

    spiciness = mkOption {
      type = lib.mkOptionType {
        name = "spiciness";
        description = "integer between 0 and 10 (merges by taking lowest)";
        check = x: builtins.isInt x && x >= 0 && x <= 10;
        merge = _loc: defs:
          lib.foldl' lib.min
            (builtins.head defs).value
            (map (def: def.value) defs);
      };
      default = 10;
      description = "맵기 정도 0~10 (여러 모듈에서 정의 시 가장 낮은 값)";
    };

    slices = mkOption {
      type = lib.mkOptionType {
        name = "slices";
        description = "non-negative integer (merges by addition)";
        check = x: builtins.isInt x && x >= 0;
        merge = _loc: defs: lib.foldl' (acc: def: acc + def.value) 0 defs;
      };
      default = 0;
      example = 8;
      description = "원하는 조각 수 (여러 모듈에서 정의 시 합산)";
    };

    order = mkOption {
      type = types.str;
      readOnly = true;
      description = "최종 주문 내역 (자동 생성)";
    };
  };

  config.pizza.order =
    let
      overlap = lib.intersectLists cfg.toppings cfg.excludedToppings;
      finalToppings =
        lib.unique (lib.subtractLists cfg.excludedToppings cfg.toppings);
    in
    assert lib.assertMsg (overlap == [ ])
      "원하는 토핑과 빼는 토핑이 겹칩니다: ${lib.concatStringsSep ", " overlap}";
    ''
      피자 주문
      - 맵기: ${toString cfg.spiciness}
      - 조각 수: ${toString cfg.slices}
      - 토핑: ${
        if finalToppings == [ ]
        then "없음"
        else lib.concatStringsSep ", " finalToppings
      }
    '';
}
