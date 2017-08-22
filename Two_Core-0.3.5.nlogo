breed [points point]
breed [anchors anchor]
breed [animals animal]
breed [tracers tracer]
breed [vertexes vertex]

tracers-own [
  departure
  goal
]

patches-own[
  quality
  id
  habitat
]

animals-own[
  energy
  last-habitat
  did-matrix?
  age

]

globals [
  available-colors
  success
  successFC
  successFC&M
  successFM
  time-in-matrix
  corridor-to-matrix-ratio
]


to setup

  clear-all
  ;________

  set-colors
  ;show available-colors
  ;________
  ask patches [set id -99]
  make-centers
  setup-patches


  ;________
  reset-ticks

end

to set-colors
  set available-colors [red yellow]
end

to make-centers


  ifelse regular? [ ; disposition fixée des points de départs

    let center-row 0
    let total-length (patch-radius * 2) + corlength
    ;print word "total length " total-length

    let remaining (max-pxcor + ( - min-pxcor)) - total-length


    ask patch 0 (min-pxcor + (remaining / 2)+ patch-radius) [make-point]
    ask patch 0 ( - (min-pxcor + (remaining / 2) + patch-radius)) [make-point]



  ]
  [ ;disposition aléatoire des points de départ

    ask one-of patches
    with [ (pxcor < (max-pxcor - (patch-radius + 4)))
      and (pxcor > (min-pxcor + (patch-radius + 4)))
      and (pycor < (max-pycor - (patch-radius + 4)))
      and (pycor > (min-pycor + (patch-radius + 4)))
    ]
    [
      ;ask patch 240 20 [
      make-point
      choose-pair
    ]
  ]


end

to make-point

  ;print available-colors
  sprout-points 1 [

    set size 6
    set shape "circle"
    set color first available-colors
    set available-colors butfirst available-colors

  ]
  ;print available-colors

end

to choose-pair
  let chosen-one one-of patches with [distance myself = corlength
    and (pxcor < (max-pxcor - (patch-radius + 4)))
    and (pxcor > (min-pxcor + (patch-radius + 4)))
    and (pycor < (max-pycor - (patch-radius + 4)))
    and (pycor > (min-pycor + (patch-radius + 4)))
  ]
  ifelse chosen-one = nobody [
    ask points [die]
    set-colors
    make-centers

  ] [
  ask chosen-one

  [make-point]

  ]

end


to setup-patches

  ask points [

    ask patches with [distance myself < patch-radius] [
      set pcolor green
      set id [who] of myself
      set habitat "patch"
    ]


  ]



end

to generate-corridor-by-ibm

  ask one-of points with [color = red] [

    layer-1
    layer-2
    layer-3

  ]

end

to layer-1

  ask patch-here [

    sprout-tracers 1 [

      set goal one-of points with [color = yellow]

    ]
  ]


  repeat corlength [

    ask tracers [

      face goal
      fd 1
      ask patches in-radius width-layer1 with [pcolor != green] [set pcolor 37 set habitat "corridor"]

    ]
  ]
  ask tracers [die]

end


to layer-2

  ask patch-here [

    sprout-tracers 1 [

      set goal one-of points with [color = yellow]

    ]
  ]


  repeat corlength [

    ask tracers [

      face goal
      fd 1
      ask patches in-radius (width-layer1 + width-layer2) with [pcolor != green and pcolor != 37] [set pcolor 33 set habitat "corridor"]

    ]
  ]
  ask tracers [die]


end


to layer-3

  ask patch-here [

    sprout-tracers 1 [

      set goal one-of points with [color = yellow]

    ]
  ]


  repeat corlength [

    ask tracers [

      face goal
      fd 1
      ask patches in-radius (width-layer1 + width-layer2 + width-layer3) with [pcolor != green and pcolor != 37 and pcolor != 33] [set pcolor 31 set habitat "corridor"]

    ]
  ]
  ask tracers [die]



end


to make-voronoi

  if vertex-number-c3 > 0 [
    if inside-c3-too? = true [
      if count patches with [pcolor = 31] > 0 [
        ask n-of vertex-number-c3 patches with [pcolor = 31] [
          sprout-vertexes 1 [
            set size 6
            set shape "triangle"
            set color one-of [41 42 43 44 45 46 47 48] ]
        ]

        ask patches with [pcolor = 31] [set pcolor [color] of min-one-of vertexes [distance myself]]
        ask vertexes [die]
      ]
    ]
  ]

  if vertex-number-c2 > 0 [
    if inside-c2-too? = true [
      if count patches with [pcolor = 33] > 0 [
        ask n-of vertex-number-c2 patches with [pcolor = 33] [
          sprout-vertexes 1 [
            set size 6
            set shape "triangle"
            set color one-of [41 42 43 44 45 46 47 48] ]
        ]

        ask patches with [pcolor = 33] [set pcolor [color] of min-one-of vertexes [distance myself]]
        ask vertexes [die]
      ]
    ]
  ]

  if vertex-number-core > 0 [
    if inside-core-too? = true [

      ask n-of vertex-number-core patches with [pcolor = 37] [
        sprout-vertexes 1 [
          set size 6
          set shape "triangle"
          set color one-of [41 42 43 44 45 46 47 48] ]
      ]

      ask patches with [pcolor = 37] [set pcolor [color] of min-one-of vertexes [distance myself]]
      ask vertexes [die]



    ]
  ]

end


to make-matrix

  let matrix-vertex-number vertex-number-matrix

  set corridor-to-matrix-ratio count patches with [habitat = "corridor"] / count patches with [pcolor = black]

  if same-grain-in-matrix? [
    set matrix-vertex-number vertex-number-matrix * 1 / corridor-to-matrix-ratio
    show matrix-vertex-number
  ]

  ifelse uniform? = true [ask patches with [pcolor = black] [set pcolor 4 set habitat "matrix"]]

  [
    ask n-of matrix-vertex-number patches with [pcolor = black] [
      sprout-vertexes 1 [
        set size 6
        set shape "triangle"
        set color one-of [21 22 23 24 25 26 27 28] ]
    ]

    ifelse vertex-number-matrix > 0 [
      ask patches with [pcolor = black] [set pcolor [color] of min-one-of vertexes [distance myself] set habitat "matrix"]
    ]
    [
    ask patches with [pcolor = black]  [set pcolor 4 set habitat "matrix"]
    ]
    ask vertexes [die]



  ]
end


to noise

  repeat noise-level [
    ask patches [set pcolor [pcolor] of one-of neighbors]
  ]

end


to set-quality

  if MatEqualCor1 = true [set C1 M1]

  ask patches with [pcolor = green] [set quality P]
  ask patches with [pcolor = 37] [set quality C1]
  ask patches with [pcolor = 33] [set quality C2]
  ask patches with [pcolor = 31] [set quality C3]
  ask patches with [pcolor = 4] [set quality M1]

  ask patches with [pcolor = 41] [set quality CV-1]
  ask patches with [pcolor = 42] [set quality CV-2]
  ask patches with [pcolor = 43] [set quality CV-3]
  ask patches with [pcolor = 44] [set quality CV-4]
  ask patches with [pcolor = 45] [set quality CV-5]
  ask patches with [pcolor = 46] [set quality CV-6]
  ask patches with [pcolor = 47] [set quality CV-7]
  ask patches with [pcolor = 48] [set quality CV-8]


  ask patches with [pcolor = 21] [set quality MV-1]
  ask patches with [pcolor = 22] [set quality MV-2]
  ask patches with [pcolor = 23] [set quality MV-3]
  ask patches with [pcolor = 24] [set quality MV-4]
  ask patches with [pcolor = 25] [set quality MV-5]
  ask patches with [pcolor = 26] [set quality MV-6]
  ask patches with [pcolor = 27] [set quality MV-7]
  ask patches with [pcolor = 28] [set quality MV-8]


end


to setup-animals

  create-animals initial-pop [

    set energy initial-energy
    set size 6
    ;move-to one-of points with [color = red]
    move-to one-of patches with [id = 0]
    if trace? = true [pen-down]
    set did-matrix? FALSE
  ]


end


to move-animals

  ask animals [

    if can-move? 1 = false [die]

    if [id] of patch-here = 1 [
      set success success + 1
      if last-habitat = "corridor" and did-matrix? = FALSE [ set successFC successFC + 1]
      if last-habitat = "corridor" and did-matrix? = TRUE [ set successFC&M successFC&M + 1]
      if last-habitat = "matrix" = TRUE [ set successFM successFM + 1]
      die
    ]

    ifelse [quality] of patch-ahead 1 = [quality] of patch-here

    [;même habitat
     ;[TODO] calcul de temps de résidence
      push ;même habitat, on avance (sinuosité décidée au temps précédent)

      if random 101 < ([quality] of patch-here) / sinuosity-divider [ ;patch-here est maitenant le patch suivant (on s'est déplacé) donc on prépare la sinuosité pour le mvt suivant

        let dir 360 * ([quality] of patch-here / 100) ;idem ; l'amplitude de virage est inversement proportionnelle à la qualité d'habitat (max 360)


        ifelse random 2 = 1 [rt dir / 2] [lt dir / 2] ;50% de chance de tourner à droite/gauche, avec une amplitude de dir/2
      ]


    ]
    [
      ifelse random 101 < ([quality] of patch-ahead 1) / emigration-divider [ ;la valeur est inférieure à la favorabilité, on considère que c'est un bon habitat et on avance

        push
      ]
      [
        rt (70 + random 40)

      ]
    ]


    if energy <= 0 [die]


  ]
  if count animals <= 0 [stop]

  tick



end


to push

  set last-habitat [habitat] of patch-here

  if [habitat] of patch-here = "matrix" [
    set time-in-matrix time-in-matrix + 1
    if did-matrix? = FALSE [set did-matrix? TRUE]
  ]

  fd 1

  ifelse different-energy-costs? = false
  [ set energy energy - 1 ]

  [ set energy energy - ( (1 - ( [quality] of patch-here / 100 ) ) * energy-multiplier ) ]


end


to reset-colors

  ask patches [

    set pcolor quality




  ]


end



to random-CV

  set CV-1 abs floor random-normal CVmean CVsd
  set CV-2 abs floor random-normal CVmean CVsd
  set CV-3 abs floor random-normal CVmean CVsd
  set CV-4 abs floor random-normal CVmean CVsd
  set CV-5 abs floor random-normal CVmean CVsd
  set CV-6 abs floor random-normal CVmean CVsd
  set CV-7 abs floor random-normal CVmean CVsd
  set CV-8 abs floor random-normal CVmean CVsd
  ;print word "CVmean " CVmean


end


to random-MV

  set MV-1 abs floor random-normal MVmean MVsd
  set MV-2 abs floor random-normal MVmean MVsd
  set MV-3 abs floor random-normal MVmean MVsd
  set MV-4 abs floor random-normal MVmean MVsd
  set MV-5 abs floor random-normal MVmean MVsd
  set MV-6 abs floor random-normal MVmean MVsd
  set MV-7 abs floor random-normal MVmean MVsd
  set MV-8 abs floor random-normal MVmean MVsd
  ;print word "MVmean " MVmean
  ;print "---"
end
@#$#@#$#@
GRAPHICS-WINDOW
7
10
808
820
-1
-1
0.8
1
10
1
1
1
0
0
0
1
-400
400
-400
400
1
1
1
ticks
30.0

BUTTON
835
11
1008
44
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

SLIDER
836
55
1008
88
corlength
corlength
0
((max-pxcor * 2) - ((2 * patch-radius)) * 1.5)
500.0
25
1
NIL
HORIZONTAL

SLIDER
836
96
1008
129
patch-radius
patch-radius
0
100
100.0
25
1
NIL
HORIZONTAL

SLIDER
1594
50
1766
83
noise-level
noise-level
0
100
5.0
1
1
NIL
HORIZONTAL

BUTTON
1040
11
1211
44
NIL
generate-corridor-by-ibm
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1040
51
1212
84
width-layer1
width-layer1
0
patch-radius
60.0
1
1
NIL
HORIZONTAL

SLIDER
1040
88
1212
121
width-layer2
width-layer2
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
1040
126
1212
159
width-layer3
width-layer3
0
100
0.0
1
1
NIL
HORIZONTAL

BUTTON
1243
12
1413
45
make voronoi
ask vertexes [die]\nmake-voronoi
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1244
54
1416
87
inside-core-too?
inside-core-too?
0
1
-1000

SLIDER
1019
233
1190
266
vertex-number-matrix
vertex-number-matrix
0
100
20.0
1
1
NIL
HORIZONTAL

BUTTON
1432
12
1583
45
NIL
make-matrix
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1433
51
1583
84
uniform?
uniform?
1
1
-1000

BUTTON
1593
13
1765
46
NIL
noise
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1784
55
1934
73
Qualités d'habitats
11
0.0
1

SLIDER
1784
79
1956
112
P
P
0
100
95.0
1
1
NIL
HORIZONTAL

SLIDER
1784
117
1956
150
C1
C1
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
1975
79
2147
112
CV-1
CV-1
0
100
72.0
1
1
NIL
HORIZONTAL

SLIDER
1975
117
2147
150
CV-2
CV-2
0
100
58.0
1
1
NIL
HORIZONTAL

SLIDER
1974
155
2146
188
CV-3
CV-3
0
100
81.0
1
1
NIL
HORIZONTAL

SLIDER
1974
192
2146
225
CV-4
CV-4
0
100
77.0
1
1
NIL
HORIZONTAL

SLIDER
1974
229
2146
262
CV-5
CV-5
0
100
85.0
1
1
NIL
HORIZONTAL

SLIDER
1974
266
2146
299
CV-6
CV-6
0
100
84.0
1
1
NIL
HORIZONTAL

SLIDER
1974
303
2146
336
CV-7
CV-7
0
100
81.0
1
1
NIL
HORIZONTAL

SLIDER
1974
340
2146
373
CV-8
CV-8
0
100
91.0
1
1
NIL
HORIZONTAL

SLIDER
1784
154
1956
187
C2
C2
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
1784
191
1956
224
C3
C3
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
2161
79
2333
112
MV-1
MV-1
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
2160
117
2332
150
MV-2
MV-2
0
100
11.0
1
1
NIL
HORIZONTAL

SLIDER
2161
156
2333
189
MV-3
MV-3
0
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
2162
194
2334
227
MV-4
MV-4
0
100
9.0
1
1
NIL
HORIZONTAL

SLIDER
2162
230
2334
263
MV-5
MV-5
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
2161
268
2333
301
MV-6
MV-6
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
2160
304
2332
337
MV-7
MV-7
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
2160
341
2332
374
MV-8
MV-8
0
100
12.0
1
1
NIL
HORIZONTAL

BUTTON
1781
13
1919
46
NIL
set-quality
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
837
416
1010
449
NIL
setup-animals
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
1391
463
1563
496
NIL
move-animals
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
837
463
1009
496
initial-pop
initial-pop
0
10000
400.0
100
1
NIL
HORIZONTAL

SLIDER
837
502
1009
535
initial-energy
initial-energy
0
10000
8000.0
1000
1
NIL
HORIZONTAL

SWITCH
1392
503
1564
536
trace?
trace?
0
1
-1000

MONITOR
838
628
1009
673
NIL
mean [energy] of animals
17
1
11

MONITOR
838
580
1009
625
NIL
count animals
17
1
11

SLIDER
1784
226
1956
259
M1
M1
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
838
832
1024
865
sinuosity-divider
sinuosity-divider
1
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
837
867
1023
900
emigration-divider
emigration-divider
1
10
1.0
1
1
NIL
HORIZONTAL

SWITCH
835
137
1009
170
regular?
regular?
0
1
-1000

BUTTON
1974
390
2150
423
random-CV
random-CV
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1977
451
2149
484
CVmean
CVmean
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
1977
487
2149
520
CVsd
CVsd
0
10
10.0
0.1
1
NIL
HORIZONTAL

SLIDER
2168
451
2340
484
MVmean
MVmean
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
2169
489
2341
522
MVsd
MVsd
0
10
4.0
0.1
1
NIL
HORIZONTAL

BUTTON
2167
391
2332
424
random-MV
random-MV
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
1941
12
2105
45
NIL
reset-colors
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
906
1120
1173
1516
différences de coûts énergétiques?...\n+ \"recharge\" de l'énergie dans les habitats favorables\n\n-->\nsi consommation des ressources + repousse : introduction d'un phénomène de concurrence... qu'est-ce que ça implique?\n--> \nsi pas de consommation + repousse : autant faire la soustraction avant et attribuer un coût \"comme si\" il y avait recharge / ou pas\n\n
18
0.0
1

BUTTON
1388
416
1459
449
do-all
no-display\nsetup\ngenerate-corridor-by-ibm\nrandom-CV\nrandom-MV\nmake-voronoi\nmake-matrix\n;noise\nset-quality\nsetup-animals\ndisplay
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
838
680
1066
725
NIL
time-in-matrix
17
1
11

MONITOR
1020
631
1103
676
NIL
successFC
17
1
11

MONITOR
1120
579
1225
624
NIL
successFC&M
17
1
11

MONITOR
1122
628
1207
673
NIL
successFM
17
1
11

MONITOR
1022
584
1089
629
NIL
success
17
1
11

MONITOR
1247
297
1587
342
NIL
corridor-to-matrix-ratio
17
1
11

SWITCH
1248
349
1589
382
same-grain-in-matrix?
same-grain-in-matrix?
1
1
-1000

SWITCH
1798
297
1955
330
MatEqualCor1
MatEqualCor1
1
1
-1000

SWITCH
839
788
1062
821
different-energy-costs?
different-energy-costs?
0
1
-1000

BUTTON
1471
416
1565
449
do-some
setup\ngenerate-corridor-by-ibm\nmake-matrix\nset-quality\nsetup-animals
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
838
746
1015
779
energy-multiplier
energy-multiplier
0
10
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
837
382
1766
427
#_______________________________________________________________________________________________________________________________________________________#
12
0.0
1

PLOT
1456
689
1849
954
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot success"
"Corridor" 1.0 0 -7500403 true "" "plot successFC"
"Matrix" 1.0 0 -2674135 true "" "plot successFM"
"DFH" 1.0 0 -955883 true "" "plot successFC&M"

SWITCH
1244
94
1416
127
inside-c2-too?
inside-c2-too?
0
1
-1000

SWITCH
1243
136
1414
169
inside-c3-too?
inside-c3-too?
0
1
-1000

BUTTON
1288
180
1351
213
sgm
setup\ngenerate-corridor-by-ibm\nmake-voronoi\nmake-matrix
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1019
341
1190
374
vertex-number-c3
vertex-number-c3
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
1019
305
1189
338
vertex-number-c2
vertex-number-c2
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
1019
268
1190
301
vertex-number-core
vertex-number-core
0
100
7.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## Changelog

###0.3.5 Cleaning and making code ready for submission.

###0.3.3 Adding the option to keep the second layer homogeneous

### 0.3.2 Cleaning GUI a little bit


### 0.3.1 adding a switch that allows to fix corridor quality to matrix quality (for basic tests purposes)
### 0.3.1 adding a switch that allows for different costs according to habitat quality (for basic tests purposes). If the switch is on, the quality cost of an habitat patch is 1 - (quality / 100) so that the cost is higher for bad patches.

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
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="cor-mat1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals
print word "C1 " C1
print word "M1 " M1
print "---"</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C1" first="0" step="5" last="100"/>
    <steppedValueSet variable="M1" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <steppedValueSet variable="MVmean" first="0" step="5" last="100"/>
    <steppedValueSet variable="CVmean" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-onion1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals
print word "C1 " C1
print word "C2 " C2
print word "M1 " M1
print "---"</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C1" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="M1">
      <value value="5"/>
      <value value="25"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C2" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor2" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <steppedValueSet variable="MVmean" first="0" step="5" last="100"/>
    <steppedValueSet variable="CVmean" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor2-VAR" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="5"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="2"/>
      <value value="4"/>
      <value value="6"/>
      <value value="8"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="2"/>
      <value value="4"/>
      <value value="6"/>
      <value value="8"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor-grain" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
      <value value="25"/>
      <value value="65"/>
    </enumeratedValueSet>
    <steppedValueSet variable="vertex-number" first="5" step="5" last="40"/>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="temoin" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="patch-radius">
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="175"/>
      <value value="275"/>
      <value value="375"/>
      <value value="475"/>
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MatEqualCor1">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="15"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="energy-basic-test" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MatEqualCor1">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-energy-costs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="M1" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="energy-basic-test-false" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MatEqualCor1">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-energy-costs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="M1" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="divider-basic-test" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MatEqualCor1">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-energy-costs?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="M1" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor-grain-corsimple2" repetitions="40" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="65"/>
    </enumeratedValueSet>
    <steppedValueSet variable="vertex-number" first="5" step="5" last="40"/>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor-grain-corsimple" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="65"/>
    </enumeratedValueSet>
    <steppedValueSet variable="vertex-number" first="5" step="5" last="40"/>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor-grain-matqual" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="65"/>
    </enumeratedValueSet>
    <steppedValueSet variable="vertex-number" first="5" step="5" last="40"/>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="energy-basic-test-multiplier" repetitions="20" runMetricsEveryStep="false">
    <setup>setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="energy-multiplier">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="6"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="575"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MatEqualCor1">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-energy-costs?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="M1" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-corridor-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="test_width" repetitions="20" runMetricsEveryStep="false">
    <setup>print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-matrix
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="patch-radius">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="5"/>
      <value value="15"/>
      <value value="25"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="5"/>
      <value value="15"/>
      <value value="25"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="10"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="10"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-multiplier">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-energy-costs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MatEqualCor1">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="21"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cor-mat-vor-c2" repetitions="30" runMetricsEveryStep="false">
    <setup>print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="10"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="5"/>
      <value value="10"/>
      <value value="50"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="grain_everywhere_simple" repetitions="30" runMetricsEveryStep="true">
    <setup>print " ----- "
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <metric>[size] of turtles</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="grain_in_core" repetitions="15" runMetricsEveryStep="false">
    <setup>print " ----- "
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="0"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="grain_in_c2" repetitions="45" runMetricsEveryStep="false">
    <setup>print " ----- "
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="0"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="grain_in_c2Xcore" repetitions="15" runMetricsEveryStep="false">
    <setup>print " ----- "
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="grain_in_c2Xc2mean" repetitions="30" runMetricsEveryStep="false">
    <setup>print " ----- "
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="global_comparison" repetitions="30" runMetricsEveryStep="false">
    <setup>print " -----  / 2160"
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="global_comparison2" repetitions="15" runMetricsEveryStep="false">
    <setup>print " -----  / 2160"
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="global_comparison3" repetitions="30" runMetricsEveryStep="false">
    <setup>print " -----  / 2160"
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="global_comparison3" repetitions="30" runMetricsEveryStep="false">
    <setup>print " -----  / 2160"
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
      <value value="10"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="grain_in_matrix" repetitions="100" runMetricsEveryStep="false">
    <setup>print " ----- / 4200 "
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <metric>corridor-to-matrix-ratio</metric>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="8"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-4">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity" repetitions="10" runMetricsEveryStep="false">
    <setup>print " ----- / 2250 "
print behaviorspace-run-number
setup
generate-corridor-by-ibm
make-voronoi
make-matrix
random-CV
random-MV
set-quality
setup-animals</setup>
    <go>move-animals</go>
    <metric>success</metric>
    <metric>successFC</metric>
    <metric>successFC&amp;M</metric>
    <metric>successFM</metric>
    <metric>time-in-matrix</metric>
    <enumeratedValueSet variable="MV-4">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sinuosity-divider">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emigration-divider">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="8"/>
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C1">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-core-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer1">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C3">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trace?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-core">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-8">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corlength">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-7">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-energy">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-energy-costs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-7">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uniform?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-6">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-4">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-2">
      <value value="58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-layer3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVmean">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="same-grain-in-matrix?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c2-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-1">
      <value value="72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MVsd">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-8">
      <value value="91"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inside-c3-too?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-1">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-multiplier">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-matrix">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-5">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C2">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-3">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-2">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MatEqualCor1">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MV-5">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVsd">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-pop">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-6">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CVmean">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CV-3">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vertex-number-c2">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
