Tween_Kind :: enum {
    LINEAR;

    IN_QUAD;
    IN_CUBIC;
    IN_QUART;
    IN_QUINT;
    IN_SINE;
    IN_EXPO;
    IN_CIRC;
    IN_BACK;
    IN_ELASTIC;
    IN_BOUNCE;

    OUT_QUAD;
    OUT_CUBIC;
    OUT_QUART;
    OUT_QUINT;
    OUT_SINE;
    OUT_EXPO;
    OUT_CIRC;
    OUT_BACK;
    OUT_ELASTIC;
    OUT_BOUNCE;

    IN_OUT_QUAD;
    IN_OUT_CUBIC;
    IN_OUT_QUART;
    IN_OUT_QUINT;
    IN_OUT_SINE;
    IN_OUT_EXPO;
    IN_OUT_CIRC;
    IN_OUT_BACK;
    IN_OUT_ELASTIC;
    IN_OUT_BOUNCE;
}

Tween :: (pointer: *$T, start: T, end: T, x: float, kind: Tween_Kind) #expand {
    pointer.* = tween(start, end, x, kind);
}

tween :: (start: $T, end: T, x: float, kind: Tween_Kind) -> T #expand {
    return start + (end - start) * tween_zero_to_one(x, kind);
}

tween_zero_to_one :: (x: float, kind: Tween_Kind) -> float #expand {
    if #complete kind == {
        case .LINEAR;         return linear(x);

        case .IN_QUAD;        return in_quad(x);
        case .IN_CUBIC;       return in_cubic(x);
        case .IN_QUART;       return in_quart(x);
        case .IN_QUINT;       return in_quint(x);
        case .IN_SINE;        return in_sine(x);
        case .IN_EXPO;        return in_expo(x);
        case .IN_CIRC;        return in_circ(x);
        case .IN_BACK;        return in_back(x);
        case .IN_ELASTIC;     return in_elastic(x);
        case .IN_BOUNCE;      return in_bounce(x);

        case .OUT_QUAD;       return out_quad(x);
        case .OUT_CUBIC;      return out_cubic(x);
        case .OUT_QUART;      return out_quart(x);
        case .OUT_QUINT;      return out_quint(x);
        case .OUT_SINE;       return out_sine(x);
        case .OUT_EXPO;       return out_expo(x);
        case .OUT_CIRC;       return out_circ(x);
        case .OUT_BACK;       return out_back(x);
        case .OUT_ELASTIC;    return out_elastic(x);
        case .OUT_BOUNCE;     return out_bounce(x);

        case .IN_OUT_QUAD;    return in_out_quad(x);
        case .IN_OUT_CUBIC;   return in_out_cubic(x);
        case .IN_OUT_QUART;   return in_out_quart(x);
        case .IN_OUT_QUINT;   return in_out_quint(x);
        case .IN_OUT_SINE;    return in_out_sine(x);
        case .IN_OUT_EXPO;    return in_out_expo(x);
        case .IN_OUT_CIRC;    return in_out_circ(x);
        case .IN_OUT_BACK;    return in_out_back(x);
        case .IN_OUT_ELASTIC; return in_out_elastic(x);
        case .IN_OUT_BOUNCE;  return in_out_bounce(x);
    }
}

#scope_file

linear :: (x: float) -> float #expand {
    return x;
}

in_quad :: (x: float) -> float #expand {
    return x * x;
}

in_cubic :: (x: float) -> float #expand {
    return x * x * x;
}

in_quart :: (x: float) -> float #expand {
    return x * x * x * x;
}

in_quint :: (x: float) -> float #expand {
    return x * x * x * x * x;
}

in_sine :: (x: float) -> float #expand {
    return 1.0 - sin((1.0 - x) * HALF_PI);
}

in_circ :: (x: float) -> float #expand {
    return 1.0 - sqrt(1.0 - x * x);
}

in_expo :: (x: float) -> float #expand {
    return pow(2.0, 10.0 * (x - 1.0));
}

in_back :: (x: float) -> float #expand {
    return x * x * ((1.0 + HALF_PI) * x - HALF_PI);
}

in_elastic :: (x: float) -> float #expand {
    return sin(13.0 * x * HALF_PI) * pow(2.0, 10.0 * (x - 1.0));
}

in_bounce :: (x: float) -> float #expand {
    if      x < 0.09090 return 0.01563 - 7.5625 * pow(0.04545 - x, 2.0);
    else if x < 0.27272 return 0.06250 - 7.5625 * pow(0.18181 - x, 2.0);
    else if x < 0.63636 return 0.25000 - 7.5625 * pow(0.45454 - x, 2.0);
    else                return 1.00000 - 7.5625 * pow(1.00000 - x, 2.0);
}

out_quad :: (x: float) -> float #expand { 
    return 1.0 - in_quad(1.0 - x); 
}

out_cubic :: (x: float) -> float #expand { 
    return 1.0 - in_cubic(1.0 - x); 
}

out_quart :: (x: float) -> float #expand { 
    return 1.0 - in_quart(1.0 - x); 
}

out_quint :: (x: float) -> float #expand { 
    return 1.0 - in_quint(1.0 - x); 
}

out_sine :: (x: float) -> float #expand { 
    return 1.0 - in_sine(1.0 - x); 
}

out_circ :: (x: float) -> float #expand { 
    return 1.0 - in_circ(1.0 - x); 
}

out_expo :: (x: float) -> float #expand { 
    return 1.0 - in_expo(1.0 - x); 
}

out_back :: (x: float) -> float #expand { 
    return 1.0 - in_back(1.0 - x); 
}

out_elastic :: (x: float) -> float #expand { 
    return 1.0 - in_elastic(1.0 - x); 
}

out_bounce :: (x: float) -> float #expand { 
    return 1.0 - in_bounce(1.0 - x); 
}

in_out_quad :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_quad(x * 2.0) else 1.0 + out_quad(x * 2.0 - 1.0)); 
}

in_out_cubic :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_cubic(x * 2.0) else 1.0 + out_cubic(x * 2.0 - 1.0)); 
}

in_out_quart :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_quart(x * 2.0) else 1.0 + out_quart(x * 2.0 - 1.0)); 
}

in_out_quint :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_quint(x * 2.0) else 1.0 + out_quint(x * 2.0 - 1.0)); 
}

in_out_sine :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_sine(x * 2.0) else 1.0 + out_sine(x * 2.0 - 1.0)); 
}

in_out_circ :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_circ(x * 2.0) else 1.0 + out_circ(x * 2.0 - 1.0)); 
}

in_out_expo :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_expo(x * 2.0) else 1.0 + out_expo(x * 2.0 - 1.0)); 
}

in_out_back :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_back(x * 2.0) else 1.0 + out_back(x * 2.0 - 1.0)); 
}

in_out_elastic :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_elastic(x * 2.0) else 1.0 + out_elastic(x * 2.0 - 1.0)); 
}

in_out_bounce :: (x: float) -> float #expand { 
    return 0.5 * (ifx x < 0.5 then in_bounce(x * 2.0) else 1.0 + out_bounce(x * 2.0 - 1.0)); 
}

HALF_PI :: PI / 2.0;

#import "Basic";
#import "Math";
