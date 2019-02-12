breed[cars car]
cars-own[spots tic tics-waited acceleration waiting?]

breed[intersections intersection]
intersections-own[up? down? right? left?]

directed-link-breed[redlinks redlink]

patches-own[direction direction? intersection?]

breed[stoplights stoplight]
stoplights-own[vert? switch maxswitch]

globals[cars-waiting]

to setup
  clear-all
  reset-ticks
  setup-colors
  make-roads
  setup-roads
  initialize-stoplights
end

to go
  spawn-cars
  move-cars
  work-stoplights
  despawn-cars
  monitor-cars-waiting
  tick
end


to setup-colors

    ask patches [set pcolor white]
    ask intersections [set color yellow set shape "flag"]

end
to make-roads
  ask patches [set intersection? false]

  make-intersections 100 1 -100 1
  make-intersections -100 -1 100 -1

  make-intersections -76 50 -76 -50
  make-intersections -74 -50 -74 50

  make-intersections -51 50 -51 -50
  make-intersections -49 -50 -49 50

  make-intersections -26 50 -26 -50
  make-intersections -24 -50 -24 50

  make-intersections 1 -50 1 50
  make-intersections -1 50 -1 -50

  make-intersections 24 50 24 -50
  make-intersections 26 -50 26 50

  make-intersections 51 -50 51 50
  make-intersections 49 50 49 -50

  make-intersections 74 50 74 -50
  make-intersections 76 -50 76 50

end

to initialize-stoplights
  make-stoplight 0 0
  make-stoplight -75 0
  make-stoplight -50 0
  make-stoplight -25 0
  make-stoplight 25 0
  make-stoplight 50 0
  make-stoplight 75 0

   ask stoplights
  [
    set vert? false
    set maxswitch stoplight-cycle-length
    set switch random maxswitch
  ]
end

to make-stoplight [x y]
  ask patch x y [sprout-stoplights 1 ]
  ask patches with [pxcor > (x - 2) and pxcor < (x + 2) and pycor > (y - 2) and pycor < (y + 2)] [set direction "fd"]


end

to make-intersections [x y xx yy]

  make-intersection x y
  make-intersection xx yy
  connect-intersections x y xx yy


end

to connect-intersections [x1 y1 x2 y2]
  ask patch x1 y1
  [
    ask intersections-here
    [
      create-redlink-to one-of intersections-on patch x2 y2
    ]
  ]
end

to make-intersection[x y]
  ask patch x y
  [
    set intersection? true
    set pcolor green
    sprout-intersections 1
  ]
end

to setup-roads
  ask patches [set direction? false]
  ask intersections
  [
    let x pxcor
    let y pycor
    ask out-link-neighbors
    [
      draw-road x y pxcor pycor
    ]
  ]
end

to draw-road [x1 y1 x2 y2];[here to there] or from [patch to patch]
  let numer (y2 - y1)
  let denom (x2 - x1)
  let g 1
  set g (GCD numer denom)
  set numer (numer / g)
  set denom (denom / g)

  if denom != 0 or numer != 0;if intersection is not on the same square
  [
    let ver-dir ""
    let hor-dir ""

    ifelse numer > 0 [set ver-dir "up"][set ver-dir "dn"]
    ifelse denom > 0 [set hor-dir "rt"][set hor-dir "lt"]

    let lastx x1
    let lasty y1

    while [lastx != x2 or lasty != y2]
    [
      ask patches with [pxcor <= max list lastx (lastx + denom) and pxcor >= min list lastx (lastx + denom) and pycor = lasty ];cordinates in the range i want, which is the last patch to the patch xdistance away horzo r vert
      [
        set direction hor-dir
        set direction? true
        set pcolor grey

      ]
      set lastx (lastx + denom);remove form loop
      ask patches with [pycor <= max list lasty (lasty + numer) and pycor >= min list lasty (lasty + numer) and pxcor = lastx ];cordinates in the range i want, which is the last patch to the patch xdistance away horzo r vert
      [
        set direction ver-dir
        set direction? true
        set pcolor grey

      ]
        set lasty (lasty + numer)
    ]



    ask patches with[pxcor = x1 and pycor = y1][set pcolor green]
    ask patches with[pxcor = x2 and pycor = y2][set direction? false]
  ]
end


to-report GCD [n d]
  if n = 0 or d = 0 [report 1]
  let num1 (abs n)
  loop
    [
      if(n mod num1 = 0) and (d mod num1 = 0)
      [
        report num1
      ]
      set num1 (num1 - 1)
    ]
  report 1
end

to work-intersections;i think this can be removed
  ask intersections
  [
    let r false
    let l false
    let u false
    let d false
    ask  patch-at 0 1
    [
      if direction? = true [ set u true]
    ]
    ask  patch-at 0 -1
    [
      if direction? = true [set d true]
    ]
    ask  patch-at 1 0
    [
      if direction? = true [set r true]
    ]
    ask  patch-at 0 -1
    [
      if direction? = true [set l true]
    ]
    set up? u
    set down? d
    set right? r
    set left? l

  ]

end






to work-stoplights;FIIIZXXX!X!!
  ask stoplights
  [
    set maxswitch stoplight-cycle-length
    if switch <= 0
    [
      ifelse vert? = true [switch-horizontal xcor ycor set switch maxswitch]
      [switch-vertical xcor ycor set switch maxswitch]
      ]


    set switch (switch - 1)
  ]

end

to switch-horizontal [x y]
  ask patch (x - 2) (y - 1) [set direction "rt"]
  ask patch (x + 2) (y + 1) [set direction "lt"]
  ask patch (x - 1) (y + 2) [set direction "st"]
  ask patch (x + 1) (y - 2) [set direction "st"]
  ask patch x y [set pcolor green]
  ask stoplights-on patch x y [set vert? false]
end
to switch-vertical [x y]
  ask patch (x - 2) (y - 1) [set direction "st"]
  ask patch (x + 2) (y + 1) [set direction "st"]
  ask patch (x - 1) (y + 2) [set direction "dn"]
  ask patch (x + 1) (y - 2) [set direction "up"]
  ask patch x y [set pcolor red]
  ask stoplights-on patch x y [set vert? true]
end


;to make-stoplights [h w trx try];height, width, top right x cor, top right y cor
; ask patch trx try [sprout-stoplights 1]
;  ask patch trx (try - (h - 1)) [sprout-stoplights 1]
;  ask patch (trx - (w - 1)) try [sprout-stoplights 1]
;  ask patch (trx - (w - 1)) (try - (h - 1)) [sprout-stoplights 1]
;
;  ask stoplights[ask patch-at 0 0 [set direction? true set direction "fd"] ]
;
;end





to spawn-cars
  ask patches with[intersection?]
    [
      if random 100 < spawn-percentage and not any? cars-on patch pxcor pycor
      [
        sprout-cars 1
        [
          set shape "car"
          set color blue
          ifelse random 10 < 1 [set spots 2 set tic 1 set color red ][set spots 1 set tic 1]
          set acceleration car-follow-distance
          set waiting? false
        ]
      ]
    ]

end

to move-cars
  let dir ""
  ask cars
  [

    let i 0
    ask patch-at 0 0 [set dir direction]
    if dir = "st" [set waiting? true]

    if not waiting?[ let w false
    ask cars-on patch-ahead 1 [if waiting?[set w waiting?]]
    set waiting? w
    ]
    while [i < spots and dir != "st"];stop
    [
    if dir = "rt" and check-ahead acceleration who and not any? cars-on patch-ahead 1;right
    [facexy (xcor + 1) ycor fd 1 set waiting? false]
    if dir = "lt" and check-ahead acceleration who and not any? cars-on patch-ahead 1;left
    [facexy (xcor - 1) ycor fd 1 set waiting? false]
    if dir = "up" and check-ahead acceleration who and not any? cars-on patch-ahead 1;up
    [facexy xcor (ycor + 1) fd 1 set waiting? false]
    if dir = "dn" and check-ahead acceleration who and not any? cars-on patch-ahead 1;down
    [facexy xcor (ycor - 1) fd 1 set waiting? false]

    if dir = "fd" [fd 1] ;forward
      set i i + 1
    ]


  ]
end

to-report check-ahead [x w]
  let move true
  let d x

  ask car w
  [
    while [d > 1]
    [
      if any? cars-on patch-ahead d  [ask cars-on patch-ahead d [set move waiting?]]
      set d (d - 1)
    ]
  ]
  report move

end

to despawn-cars
  ask cars
  [
    ask patch-at 0 0
    [
      if not direction?
      [
        ask cars-here [die]
      ]
    ]
  ]
end

to monitor-cars-waiting

   let summ 0
   ask cars[ if waiting?[set summ (summ + 1)]]
   set cars-waiting summ

   let sum2 0
   ask cars[ if waiting?[set sum2 (sum2 + 1)]]
   set cars-waiting summ
end
to reset-acceleration
  ask cars[set acceleration car-follow-distance]
end

to syncronize-lights
  ask stoplights
  [
    switch-horizontal xcor ycor
    set maxswitch stoplight-cycle-length
    set switch maxswitch
  ]
end
to randomize-lights
  ask stoplights
  [
    ifelse random 2 > 0[switch-horizontal xcor ycor][switch-vertical xcor ycor]
    set maxswitch stoplight-cycle-length
    set switch (random maxswitch)
  ]
end
to cascade-lights

end
@#$#@#$#@
GRAPHICS-WINDOW
291
10
1404
624
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-110
110
-60
60
0
0
1
ticks
30.0

BUTTON
73
52
139
85
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
72
115
135
148
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
25
178
226
211
stoplight-cycle-length
stoplight-cycle-length
0
750
50.0
1
1
NIL
HORIZONTAL

SLIDER
23
233
195
266
car-follow-distance
car-follow-distance
1
9
4.0
1
1
NIL
HORIZONTAL

PLOT
10
318
210
468
Percent of Cars Waiting
tick
Percent
0.0
10.0
0.0
50.0
true
false
"" "if ticks mod 1500 = 0 and ticks > 1000 \n[ \n set stoplight-cycle-length (stoplight-cycle-length + 5 )\n]\n\nset-plot-pen-color black\nif stoplight-cycle-length <= 35  [set-plot-pen-color red]\nif stoplight-cycle-length <= 30[set-plot-pen-color orange]\nif stoplight-cycle-length <= 25 [set-plot-pen-color green]\nif stoplight-cycle-length <= 20 [set-plot-pen-color cyan]\nif stoplight-cycle-length <= 15 [set-plot-pen-color blue]\nif stoplight-cycle-length <= 10 [set-plot-pen-color violet]\nif stoplight-cycle-length <= 5 [set-plot-pen-color magenta]\nif stoplight-cycle-length <= 1 [set-plot-pen-color black]"
PENS
"default" 1.0 0 -13345367 true "" "if count cars > 0 and ticks > 1000[plot (cars-waiting) * 100 / (count cars)]"

SLIDER
23
277
195
310
spawn-percentage
spawn-percentage
0
100
5.0
1
1
NIL
HORIZONTAL

BUTTON
38
497
182
530
NIL
reset-acceleration
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
210
369
289
414
NIL
count cars
17
1
11

BUTTON
37
551
178
584
NIL
syncronize-lights
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
37
587
176
620
NIL
randomize-lights
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
