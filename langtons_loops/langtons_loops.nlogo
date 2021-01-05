patches-own [ previous_state current_state ]

to setup
  ca
  reset-ticks
  set_initial_state
end

to go
  calculate_new_state
  tick
end

to set_initial_state
  let initial_state [
    [0 2 2 2 2 2 2 2 2 0 0 0 0 0 0]
    [2 1 7 0 1 4 0 1 4 2 0 0 0 0 0]
    [2 0 2 2 2 2 2 2 0 2 0 0 0 0 0]
    [2 7 2 0 0 0 0 2 1 2 0 0 0 0 0]
    [2 1 2 0 0 0 0 2 1 2 0 0 0 0 0]
    [2 0 2 0 0 0 0 2 1 2 0 0 0 0 0]
    [2 7 2 0 0 0 0 2 1 2 0 0 0 0 0]
    [2 1 2 2 2 2 2 2 1 2 2 2 2 2 0]
    [2 0 7 1 0 7 1 0 7 1 1 1 1 1 2]
    [0 2 2 2 2 2 2 2 2 2 2 2 2 2 0]]

  ;; if even width, x starts at 10 units left of center of x-axis.
  let x (world-width / 2) - 10

  ;; if odd width, x starts 11 units left of center of x-axis
  if ((world-width mod 2) = 1) [
    set x ((world-width - 1) / 2) - 10
  ]

  ;; if even height, y starts 5 units above center of y-axis.
  let y (world-height / 2) + 5

  ;; if non-even height, y starts 6 units above center of y-axis.
  if ((world-height mod 2) = 1) [
    set y ((world-height - 1)/ 2) + 5
  ]

  let col 0
  while [col < (15)][
    let offset 0
    let row 0
    while [offset < 10] [
      ask patch x (y - offset) [set previous_state (item col (item row initial_state))]

      set offset offset + 1
      set row row + 1
    ]
    set x (x + 1)
    set col (col +  1)
  ]

  ask patches with [previous_state != 0][set pcolor (colour previous_state)]
end


;; returns color value based on predefined mapping
to-report colour [ value ]
  if(value = 0)[ report black ]
  if(value = 1)[ report blue ]
  if(value = 2)[ report red ]
  if(value = 3)[ report green ]
  if(value = 4)[ report yellow ]
  if(value = 5)[ report pink ]
  if(value = 6)[ report white ]
  if(value = 7)[ report cyan ]
end

to calculate_new_state
  ask patches with [pxcor < max-pxcor and pxcor > min-pxcor and
    pycor < max-pycor and pycor > min-pycor] [

    let north 0
    let east 0
    let south 0
    let west 0

    ask patch-at 0 1 [set north previous_state]
    ask patch-at 1 0 [set east previous_state]
    ask patch-at 0 -1 [set south previous_state]
    ask patch-at -1 0 [set west previous_state]

    let new_state (rule_table previous_state north east south west)

    ;; rotate4 symmetry - transition function covers one of four possibilities,
    ;; may possibly need to run four times, once per each possibility
    ifelse(new_state != -1)[
      set current_state new_state
    ][
      set new_state (rule_table previous_state west north east south)
      ifelse(new_state != -1)[
        set current_state new_state
      ][
        set new_state (rule_table previous_state south west north east)
        ifelse(new_state != -1)[
          set current_state new_state
        ][
          set new_state (rule_table previous_state east south west north)
          if(new_state != -1)[
            set current_state new_state
          ]
        ]
      ]
    ]
    set pcolor (colour new_state)
  ]

  ;; change current state last, force synchronicity, do not want asynchronicity
  ask patches with [previous_state != current_state][
    set previous_state current_state
  ]
end

;; very long transition function, moved to the bottom for ease of access to other methods
;; modified from original version for increased efficiency, otherwise too slow
to-report rule_table [ center north east south west ]
  if (center = 0 ) [
    if (north = 0) [
      if (east = 0) [
        if (south = 0) [
          if (west = 0) [ report 0 ]
          if (west = 1) [ report 2 ]
          if (west = 2) [ report 0 ]
          if (west = 3) [ report 0 ]
          if (west = 5) [ report 0 ]
          if (west = 6) [ report 3 ]
          if (west = 7) [ report 1 ]
        ]
        if (south = 1) [
          if (west = 1) [ report 2 ]
          if (west = 2) [ report 2 ]
          if (west = 3) [ report 2 ]
        ]
        if (south = 2) [
          if (west = 1) [ report 2 ]
          if (west = 2) [ report 0 ]
          if (west = 3) [ report 0 ]
          if (west = 6) [ report 2 ]
          if (west = 7) [ report 2 ]
        ]
        if (south = 3) [
          if (west = 2) [ report 0 ]
        ]
        if (south = 5) [
          if (west = 2) [ report 5 ]
        ]
        if (south = 6) [
          if (west = 2) [ report 2 ]
        ]
        if (south = 7) [
          if (west = 2) [ report 2 ]
        ]
      ]
      if (east = 1) [
        if (south = 0) [
          if (west = 2) [ report 2 ]
        ]
        if (south = 1) [
          if (west = 2) [ report 0 ]
        ]
      ]
      if (east = 2) [
        if (south = 0) [
          if (west = 2) [ report 0 ]
          if (west = 3) [ report 0 ]
          if (west = 5) [ report 0 ]
        ]
        if (south = 1) [
          if (west = 2) [ report 5 ]
        ]
        if (south = 2) [
          if (west = 2) [ report 0 ]
        ]
        if (south = 3) [
          if (west = 2) [ report 2 ]
        ]
      ]
      if (east = 5) [
        if (south = 2 and west = 2)[ report 2 ]
      ]
    ]
    if (north = 1) [
      if (east = 2) [
        if (south = 3) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 4) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 5) [
          if (west = 2) [ report 5 ]
        ]
        if (south = 6) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 7) [
          if (west = 2) [ report 1 ]
          if (west = 5) [ report 1 ]
        ]
      ]
      if (east = 4) [
        if (south = 2) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 3) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 4) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 7) [
          if (west = 2) [ report 1 ]
        ]
      ]
      if (east = 6) [
        if (south = 2 and west = 5)[ report 1 ]
      ]
      if (east = 7) [
        if (south = 2) [
          if (west = 2) [ report 1 ]
          if (west = 5) [ report 5 ]
        ]
        if (south = 5) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 6) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 7) [
          if (west = 2) [ report 1 ]
        ]
      ]
    ]
    if (north = 2) [
      if (east = 5 and south = 2 and west = 7)[ report 1 ]
    ]
  ]

  if (center = 1 ) [
    if (north = 0) [
      if (east = 0) [
        if (south = 0) [
          if (west = 1) [ report 1 ]
          if (west = 6) [ report 1 ]
          if (west = 7) [ report 7 ]
        ]
        if (south = 1) [
          if (west = 1) [ report 1 ]
          if (west = 2) [ report 1 ]
        ]
        if (south = 2) [
          if (west = 1) [ report 1 ]
          if (west = 4) [ report 4 ]
          if (west = 7) [ report 7 ]
        ]
        if (south = 5) [
          if (west = 1) [ report 1 ]
        ]
      ]
      if (east = 1) [
        if (south = 0) [
          if (west = 1) [ report 1 ]
        ]
        if (south = 1) [
          if (west = 1) [ report 1 ]
        ]
        if (south = 2) [
          if (west = 4) [ report 4 ]
          if (west = 7) [ report 7 ]
        ]
      ]
      if (east = 2) [
        if (south = 0) [
          if (west = 2) [ report 6 ]
        ]
        if (south = 1) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 2) [
          if (west = 1) [ report 1 ]
          if (west = 4) [ report 4 ]
          if (west = 6) [ report 3 ]
          if (west = 7) [ report 7 ]
        ]
        if (south = 3) [
          if (west = 2) [ report 7 ]
        ]
        if (south = 4) [
          if (west = 2) [ report 4 ]
        ]
        if (south = 6) [
          if (west = 2) [ report 6 ]
          if (west = 4) [ report 4 ]
          if (west = 7) [ report 7 ]
        ]
        if (south = 7) [
          if (west = 1) [ report 0 ]
          if (west = 2) [ report 7 ]
        ]
      ]
      if (east = 5) [
        if (south = 4 and west = 2) [ report 7 ]
      ]
    ]
    if (north = 1) [
      if (east = 1) [
        if (south = 1) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 2) [
          if (west = 2) [ report 1 ]
          if (west = 4) [ report 4 ]
          if (west = 5) [ report 1 ]
          if (west = 6) [ report 1 ]
          if (west = 7) [ report 7 ]
        ]
        if (south = 5) [
          if (west = 2) [ report 2 ]
        ]
      ]
      if (east = 2) [
        if (south = 1) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 2) [
          if (west = 2) [ report 1 ]
          if (west = 4) [ report 4 ]
          if (west = 5) [ report 1 ]
          if (west = 7) [ report 7 ]
        ]
        if (south = 3) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 4) [
          if (west = 2) [ report 4 ]
        ]
        if (south = 6) [
          if (west = 2) [ report 1 ]
        ]
        if (south = 7) [
          if (west = 2) [ report 7 ]
        ]
      ]
      if (east = 3) [
        if(south = 2 and west = 2)[ report 1 ]
      ]
    ]
    if (north = 2) [
      if (east = 2) [
        if (south = 2) [
          if (west = 4) [ report 4 ]
          if (west = 7) [ report 7 ]
        ]
        if (south = 4 and west = 3) [ report 4 ]
        if (south = 5 and west = 4) [ report 7 ]
      ]
      if (east = 3) [
        if (south = 2 and west = 4) [ report 4 ]
        if (south = 2 and west = 7) [ report 7 ]
      ]
      if (east = 4) [
        if (south = 2 and west = 5) [ report 5 ]
        if (north = 2 and east = 4 and south = 2 and west = 6) [ report 7 ]
      ]
      if (east = 5) [
        if (south = 2 and west = 7) [ report 5 ]
      ]
    ]
  ]



  if (center = 2 ) [
    if (north = 0) [
      if (east = 0) [
        if (south = 0) [
          if (west = 1) [ report 2 ]
          if (west = 2) [ report 2 ]
          if (west = 4) [ report 2 ]
          if (west = 7) [ report 1 ]
        ]
        if (south = 1) [
          if (west = 2) [ report 2 ]
          if (west = 5) [ report 2 ]
        ]
        if (south = 2) [
          if (west = 1) [ report 2 ]
          if (west = 2) [ report 2 ]
          if (west = 3) [ report 2 ]
          if (west = 4) [ report 2 ]
          if (west = 5) [ report 0 ]
          if (west = 6) [ report 2 ]
          if (west = 7) [ report 2 ]
        ]
        if (south = 3) [
          if (west = 2) [ report 6 ]
        ]
        if (south = 4) [
          if (west = 2) [ report 3 ]
        ]
        if (south = 5) [
          if (west = 1) [ report 7 ]
          if (west = 2) [ report 2 ]
          if (west = 7) [ report 5 ]
        ]
        if (south = 7 and west = 2) [ report 2 ]
      ]
      if (east = 1) [
        if (south = 0 and west = 2) [ report 2 ]
        if (south = 1 and west = 2) [ report 2 ]
        if (south = 2 and west = 2) [ report 2 ]
        if (south = 4 and west = 2) [ report 2 ]
        if (south = 7 and west = 2) [ report 2 ]
      ]
      if (east = 2) [
        if (south = 0) [
          if (west = 2) [ report 2 ]
          if (west = 3) [ report 2 ]
          if (west = 5) [ report 2 ]
          if (west = 7) [ report 3 ]
        ]
        if (south = 1) [
          if (west = 2) [ report 2 ]
          if (west = 5) [ report 2 ]
        ]
        if (south = 2) [
          if (west = 1) [ report 2 ]
          if (west = 2) [ report 2 ]
          if (west = 7) [ report 2 ]
        ]
        if (south = 3) [
          if(west = 2) [ report 1 ]
        ]
        if (south = 4) [
          if (west = 2) [ report 2 ]
          if (west = 5) [ report 2 ]
        ]
        if (south = 5) [
          if (west = 2) [ report 0 ]
          if (west = 5) [ report 2 ]
        ]
        if (south = 6 and west = 2) [ report 2 ]
        if (south = 7 and west = 2) [ report 2 ]
      ]
      if (east = 3) [
        if (south = 1 and west = 2) [ report 2 ]
        if (south = 2 and west = 1) [ report 6 ]
        if (south = 2 and west = 2) [ report 6 ]
        if (south = 4 and west = 2) [ report 2 ]
      ]
      if (east = 4) [
        if (south = 2 and west = 2) [ report 2 ]
      ]
      if (east = 5) [
        if (south = 1 and west = 2) [ report 2 ]
        if (south = 2) [
          if (west = 1) [ report 2 ]
          if (west = 2) [ report 2 ]
        ]
        if (south = 5 and west = 2) [ report 1 ]
        if (south = 7 and west = 2) [ report 5 ]
      ]
      if (east = 6) [
        if (south = 2 and west = 2) [ report 2 ]
        if (south = 7 and west = 2) [ report 2 ]
      ]
      if (east = 7) [
        if (south = 1 and west = 2) [ report 2 ]
        if (south = 2 and west = 2) [ report 2 ]
        if (south = 4 and west = 2) [ report 2 ]
        if (south = 7 and west = 2) [ report 2 ]
      ]
    ]
    if (north = 1) [
      if (east = 1) [
        if (south = 2 and west = 2) [ report 2 ]
        if (south = 2 and west = 6) [ report 1 ]
      ]
      if (east = 2) [
        if (south = 2 and west = 2) [ report 2 ]
        if (south = 2 and west = 4) [ report 2 ]
        if (south = 2 and west = 6) [ report 2 ]
        if (south = 2 and west = 7) [ report 2 ]
      ]
      if (east = 4 and south = 2 and west = 2) [ report 2 ]
      if (east = 5 and south = 2 and west = 2) [ report 2 ]
      if (east = 6 and south = 2 and west = 2) [ report 2 ]
      if (east = 7 and south = 2 and west = 2) [ report 2 ]

    ]
    if (north = 2) [
      if (east = 2) [
        if (south = 2 and west = 7) [ report 2 ]
        if (south = 4) [
          if (west = 4) [ report 2 ]
          if (west = 6) [ report 2 ]
        ]
        if (south = 7) [
          if (west = 6) [ report 2 ]
          if (west = 7) [ report 2 ]
        ]
      ]
    ]
  ]

  if (center = 3 ) [
    if (north = 0) [
      if (east = 0) [
        if (south = 0) [
          if (west = 1) [ report 3 ]
          if (west = 2) [ report 2 ]
          if (west = 4) [ report 1 ]
          if (west = 7) [ report 6 ]
        ]
        if (south = 1 and west = 2) [ report 3 ]
        if (south = 4 and west = 2) [ report 1 ]
        if (south = 6 and west = 2) [ report 2 ]
      ]
      if (east = 1) [
        if (north = 0 and east = 1 and south = 0 and west = 2) [ report 1 ]
        if (north = 0 and east = 1 and south = 2 and west = 2) [ report 0 ]
      ]
      if (east = 2 and south = 5 and west = 1) [ report 1 ]
    ]
  ]

  if (center = 4 ) [
    if (north = 0) [
      if (east = 1) [
        if (south = 1 and west = 2) [ report 0 ]
        if (south = 2 and west = 2) [ report 0 ]
        if (south = 2 and west = 5) [ report 0 ]
      ]
      if (east = 2) [
        if (south = 1 and west = 2) [ report 0 ]
        if (south = 2 and west = 2) [ report 1 ]
        if (south = 3 and west = 2) [ report 6 ]
        if (south = 5 and west = 2) [ report 0 ]
      ]
      if (east = 3 and south = 2 and west = 2) [ report 1 ]
    ]
  ]

  if (center = 5 ) [
    if (north = 0) [
      if (east = 0) [
        if (south = 0 and west = 2) [ report 2 ]
        if (south = 2) [
          if (west = 1) [ report 5 ]
          if (west = 2) [ report 5 ]
          if (west = 3) [ report 2 ]
          if (west = 7) [ report 2 ]
        ]
        if (south = 5 and west = 2) [ report 0 ]
      ]
      if (east = 2) [
        if (south = 0 and west = 2) [ report 2 ]
        if (south = 1) [
          if (west = 2) [ report 2 ]
          if (west = 5) [ report 2 ]
        ]
        if (south = 2) [
          if (west = 2) [ report 0 ]
          if (west = 4) [ report 4 ]
        ]
        if (south = 7 and west = 2) [ report 2 ]
      ]
    ]
    if (north = 1) [
      if (east = 2) [
        if (south = 1 and west = 2) [ report 2 ]
        if (south = 2 and west = 2) [ report 0 ]
        if (south = 4 and west = 2) [ report 2 ]
        if (south = 7 and west = 2) [ report 2 ]
      ]
    ]
  ]

  if (center = 6 ) [
    if (north = 0) [
      if (east = 0) [
        if (south = 0) [
          if (west = 1) [ report 1 ]
          if (west = 2) [ report 1 ]
        ]
      ]
      if (east = 2 and south = 1 and west = 2)[ report 0 ]
    ]
    if (north = 1) [
      if (east = 2) [
        if (south = 1) [
          if (west = 2) [ report 5 ]
          if (west = 3) [ report 1 ]
        ]
        if (south = 2 and west = 2) [ report 5 ]
      ]
    ]
  ]

  if (center = 7 ) [
    if (north = 0) [
      if (east = 0 and south = 0 and west = 7) [ report 7 ]
      if (east = 1) [
        if (south = 1 and west = 2) [ report 0 ]
        if (south = 2) [
          if (west = 2) [ report 0 ]
          if (west = 5) [ report 0 ]
        ]
      ]
      if (east = 2) [
        if (south = 1 and west = 2) [ report 0 ]
        if (south = 2) [
          if (west = 2) [ report 1 ]
          if (west = 5) [ report 1 ]
        ]
        if (south = 3 and west = 2) [ report 1 ]
        if (south = 5 and west = 2) [ report 5 ]
        if (south = 7 and west = 2) [ report 0 ]
      ]
    ]
  ]
  report -1
end
@#$#@#$#@
GRAPHICS-WINDOW
210
9
750
550
-1
-1
7.0
1
5
1
1
1
0
0
0
1
0
75
0
75
0
0
1
ticks
30.0

BUTTON
18
21
87
60
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
96
21
166
61
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

BUTTON
30
84
155
117
step
go
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
## So what is it?

Langton's Loops (LL) is a cellular automaton, created in 1984 by Christopher Langton. More specifically, LL is a form of artifical life called a self-replicating automaton, which, as the name implies, means that individual loops can replicate and form additional loops. Reproduction can continue on infinitely, or until the system runs out of available space for additional loops.

Each loop is made of genetic information that continually flows around the loop and along an 'arm' (or pseudopod), which will eventually split off and become a separate, independent loop capable of reproduction.

## Neighbourhood

Langton's Loops uses the von Neumann neighbourhood, which means that a cell's neighbours consist only of the four cells immediately above, below, left, and right of it. In other terms, only the cells that share an edge with the center cell are considered neighbours.

## States
In a cellular automata, each cell has a state and there are finitely many states.
Typically, a cell's state corresponds to its colour. Langton's Loops utilises eight states, which are listed below (unfortunately netlogo's markdown does not support tables).

**state -> colour**
0 -> black
1 -> blue
2 -> red
3 -> green
4 -> yellow
5 -> pink
6 -> white
7 -> cyan

## Transition Function

The rules that the agents use to create the global behavior of the model are represented in the [transition table](https://github.com/galgocmc/self-replicating_automata/blob/main/langtons_loops/transition_function.table) for a total of 219 rules, based on the state of each given cell and the states of its four neighbours.

The function in its condensed form consists of lines of 6 single-digit numbers. The first number refers to the state of the center cell, the next four numbers refer to the states of the center's neighbours (in the order of north, east, south, west), and the last number refers to the function output.

Consider line 186 from the table: 
>`402520`

This tells us that if a center cell has a state of `4`, and its neighbours have states of `0, 2, 5, 2`, then the function will return `0`.

### High quality graphical rendering:
<pre>  0
2 4 2  ->  0
  5</pre>


However, life is not that simple. The neighbourhood uses a rotational symmetry which means the transition function only considers one of four possibilities. Thus all four may need to be checked for the transition function to produce an output.

To understand the rotational symmetry, consider the following example:
A given cell with state 0 has four neighbours, `[1, 2, 3, 4]`, in the order north, east, south, west.
Then, we must check four possible inputs to the transition function: 

>`[0, 1, 2, 3, 4], [0, 2, 3, 4, 1], [0, 3, 4, 1, 2],` and `[0, 4, 1, 2, 3]`.

Each possibility cooresponds to a rotation of the original list of neighbours. The neighbour list 
`[1, 3, 2, 4]` does not need to be checked, as this does not correspond to a rotation of the original list of neighbours.

### High quality graphical rendering:
<pre>  1        2        3        4     |          1
4 0 2    1 0 3    2 0 4    3 0 1   |  <u><b>NOT</b></u>   4 0 3
  3        4        1        2     |          2</pre>

The order in which the different possibilities are checked does not matter. Only one will produce output from the transition function.

## Credits/Links

[Original Netlogo file](ccl.northwestern.edu/netlogo/community/Loop%20de%20Langton%202.nlogo)
[Langton article on self-reproducing automata](http://deepblue.lib.umich.edu/bitstream/handle/2027.42/24968/0000395.pdf?sequence=1)

### Additional information:
[Langton's Loops Wikipedia](https://en.wikipedia.org/wiki/Langton%27s_loops)
[Cellular Automata Wikipedia](https://en.wikipedia.org/wiki/Codd%27s_cellular_automaton)
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

check
false
0
Polygon -7500403 true true 55 138 22 155 53 196 72 232 91 288 111 272 136 258 147 220 167 174 208 113 280 24 257 7 192 78 151 138 106 213 87 182

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

die 1
false
0
Rectangle -7500403 true true 45 45 255 255
Circle -16777216 true false 129 129 42

die 2
false
0
Rectangle -7500403 true true 45 45 255 255
Circle -16777216 true false 69 69 42
Circle -16777216 true false 189 189 42

die 3
false
0
Rectangle -7500403 true true 45 45 255 255
Circle -16777216 true false 69 69 42
Circle -16777216 true false 129 129 42
Circle -16777216 true false 189 189 42

die 4
false
0
Rectangle -7500403 true true 45 45 255 255
Circle -16777216 true false 69 69 42
Circle -16777216 true false 69 189 42
Circle -16777216 true false 189 69 42
Circle -16777216 true false 189 189 42

die 5
false
0
Rectangle -7500403 true true 45 45 255 255
Circle -16777216 true false 69 69 42
Circle -16777216 true false 129 129 42
Circle -16777216 true false 69 189 42
Circle -16777216 true false 189 69 42
Circle -16777216 true false 189 189 42

die 6
false
0
Rectangle -7500403 true true 45 45 255 255
Circle -16777216 true false 84 69 42
Circle -16777216 true false 84 129 42
Circle -16777216 true false 84 189 42
Circle -16777216 true false 174 69 42
Circle -16777216 true false 174 129 42
Circle -16777216 true false 174 189 42

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

orbit 1
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 false true 41 41 218

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
NetLogo 6.0.2
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
