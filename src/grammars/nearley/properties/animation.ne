@builtin "whitespace.ne"

@{%
  const moo = require("moo");

  const lexer = moo.compile({
    singleTimingFunction: ["linear", "ease", "ease-in", "ease-out", "ease-in-out"],
    none: "none",
    all: "all",
    infinite: "infinite",
    singleAnimationDirection: ["normal", "reverse", "alternate", "alternate-reverse"],
    singleAnimationFillMode: ["none", "forwards", "backwards", "both"],
    singleAnimationPlayState: ["running", "paused"],
    functionStart: /[a-zA-Z\-]+\(/,
    ident: {
      match: /[a-zA-Z_][a-zA-Z0-9\-_]*/,
      keywords: {
        singleTimingFunction: ["linear", "ease", "ease-in", "ease-out", "ease-in-out"],
        none: "none",
        all: "all",
        infinite: "infinite",
        singleAnimationDirection: ["normal", "reverse", "alternate", "alternate-reverse"],
        singleAnimationFillMode: ["none", "forwards", "backwards", "both"],
        singleAnimationPlayState: ["running", "paused"],
        timeUnit: ["s", "ms"],
      }
    },
    string: /(?:"[^"]*")|(?:'[^']*')/,
    number: /(?:\+|\-)?(?:[0-9]+\.[0-9]*)|(?:[0-9]*\.[0-9]+)/,
    integer: /(?:\+|\-)?[0-9]+/,
    timeUnit: ["s", "ms"],
    char: /./,
  });
%}

@lexer lexer

Base -> ( ( SingleAnimation _ "," _):* SingleAnimation ) {% function (data,location) { return { name: 'Base', values: data.filter(Boolean), location }; } %}
SingleAnimation -> ( Time | SingleTimingFunction | Time | SingleAnimationIterationCount | SingleAnimationDirection | SingleAnimationFillMode | SingleAnimationPlayState | ( ( "none" | KeyframesName ) ) ) ( __ ( Time | SingleTimingFunction | Time | SingleAnimationIterationCount | SingleAnimationDirection | SingleAnimationFillMode | SingleAnimationPlayState | ( ( "none" | KeyframesName ) ) ) ):* {% function (data,location) { return { name: 'SingleAnimation', values: data.filter(Boolean), location }; } %}
Time -> Number %timeUnit {% function (data,location) { return { name: 'Time', values: data.filter(Boolean), location: lexer.index }; } %}
SingleTimingFunction -> ( ( ( "linear" | CubicBezierTimingFunction ) | StepTimingFunction ) | FramesTimingFunction ) {% function (data,location) { return { name: 'SingleTimingFunction', values: data.filter(Boolean), location }; } %}
SingleAnimationIterationCount -> ( "infinite" | Number ) {% function (data,location) { return { name: 'SingleAnimationIterationCount', values: data.filter(Boolean), location }; } %}
SingleAnimationDirection -> ( ( ( "normal" | "reverse" ) | "alternate" ) | "alternate-reverse" ) {% function (data,location) { return { name: 'SingleAnimationDirection', values: data.filter(Boolean), location }; } %}
SingleAnimationFillMode -> ( ( ( "none" | "forwards" ) | "backwards" ) | "both" ) {% function (data,location) { return { name: 'SingleAnimationFillMode', values: data.filter(Boolean), location }; } %}
SingleAnimationPlayState -> ( "running" | "paused" ) {% function (data,location) { return { name: 'SingleAnimationPlayState', values: data.filter(Boolean), location }; } %}
KeyframesName -> ( CustomIdent | String ) {% function (data,location) { return { name: 'KeyframesName', values: data.filter(Boolean), location }; } %}
Number -> ( %number | %integer )
CubicBezierTimingFunction -> ( "ease" | "ease-in" | "ease-out" | "ease-in-out" | "cubic-bezier(" _ Number _ "," _ Number _ "," _ Number _ "," _ Number _ ")" )
StepTimingFunction -> ( ( "step-start" | "step-end" ) | ( ( ( ( "steps(" _ Integer ) _ ( ( "," _ ( ( "start" | "end" ) ) ) ):? ) _ ")" ) ) )
FramesTimingFunction -> "frames(" _ Integer _ ")"
Integer -> %integer
CustomIdent -> %ident
String -> %string