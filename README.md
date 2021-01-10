# Self Replicating Automata
This repository contains visual implementations of several self-replicating automata (SRA). In simple terms, an SRA is an automata that is able to create a self-sufficient, independent copy of itself. The idea of an SRA was first proposed by John Von Neumann with his [Universal Constructor (UC)](https://en.wikipedia.org/wiki/Von_Neumann_universal_constructor). Von Neumann's intention was to mimic a Turing Machine capable of creating a separate, identical Turning Machine, which could then create another, and so on. Von Neumann's UC was incredibly complex, consisting of 29 different possible states and is not practical to view in a live simulation. However, the UC was later rendered obsolete by Edgar F. Codd (who is perhaps more notable for having created the relational data model in the late 1970's), who, in 1968, proposed a [simplified universal contructor](https://en.wikipedia.org/wiki/Codd%27s_cellular_automaton) that only required 8 states. Codd's model ultimately inspired those found in this repository. <!--Each subsiquent SRA was inspired by Codd's simplified version.-->

## Recommended order of viewing

1. [Langtons Loops](https://github.com/galgocmc/self-replicating_automata/tree/main/langtons_loops)
2. [SDSR Loops](https://github.com/galgocmc/self-replicating_automata/tree/main/sdsr_loops)
3. [Evoloops](https://github.com/galgocmc/self-replicating_automata/tree/main/evoloops)

## Definition of self-replication
In Langton's original paper, he describes a scenario quite similar to [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life), in which cells can exists in one of two states: alive or blank. Langton poses the following qustion: if a blank cell becomes alive, does this mean that another cell or cells has/have reproduced? The answer is a resounding no, as this is simply too primitive. As Langton describes, the cell is induced into a living state 'by the transition "physics"'. In order to reproduce, the copy must be 'actively directed by the configuration itself'. There is more to the definiton that can be found in the aforementioned paper, but understand that self-replication is a bit more nuanced than it may appear on the surface.

## Sources
<a href='https://github.com/jimblandy/golly' target='_blank'>Rule Tables</a> *This repository was incredibly helpful as t contains rule tables and initial configurations for all types of loops and this project` couldn't have happened without it*

[Langton's Loops Wikipedia](https://en.wikipedia.org/wiki/Langton%27s_loops) *Not particularily useful but some information about LL as well as the subsequent loops based on LL*

[Golly Wikipedia Page](https://en.wikipedia.org/wiki/Golly_(program)) *Golly is a simulation tool for cellular automata that runs much better than the implementations found here and really helped with accuracy checking*
