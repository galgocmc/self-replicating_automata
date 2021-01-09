import java.util.*;
import java.io.*;
// ##### key mapping for controls #####
// TAB    resets the program back to the beginning
// SPACE  pauses/unpauses the program
// ENTER  advances the model one iteration, only works whilst paused
// t      toggles turbo mode- runs much faster, but makes it hard to see each individual iteration

// 2d array to hold cell matrix
cell[][] cells;
HashMap<String, Integer> trans_table;


// width of individual cells in the cellular automata
int cell_width = 6;
// how many cells wide, how many cells tall
int area_width = 175, area_height = 140;

// control variables
boolean pause = false;
boolean turbo = true;

int offset = 0;

void settings() {
  size(displayWidth-75, displayHeight-75);
}

void setup() {
  create_transition_function();
  create_cells();
  set_initial_state();
  backgrnd();

  display_cells(false);
}

void create_transition_function() {
  trans_table = new HashMap<String, Integer>();
  try {
    String filename = "/Users/michaelgalgoczy/Documents/self-replicating_automata/evoloops";
    filename += "/evoloops_processing/transition_function.table";

    Scanner scan = new Scanner(new File(filename));
    while (scan.hasNextLine()) {
      String line = (scan.nextLine()).replace("\n", "");
      trans_table.put(line.substring(0, 5), Character.getNumericValue(line.charAt(5)));
    }

    scan.close();
  }
  catch (Exception e) {
    e.printStackTrace(System.err);
    System.exit(-1);
  }
}

// paints the nice gradient for the background
void backgrnd() {
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {     
      set(i, j, lerpColor(#43CEA2, #185A9D, (float) i / width));
    }
  }
}

void create_cells() {
  // centers the grid within the processing window
  int start_x = abs((width - (area_width * cell_width)) / 2);
  int start_y = abs((height - (area_height * cell_width)) / 2);

  cells = new cell[area_width][];
  for (int i = 0; i < cells.length; i++) {
    cells[i] = new cell[area_height];
    for (int j = 0; j < cells[i].length; j++) {
      cells[i][j] = new cell(start_x + cell_width * i, start_y + cell_width * j);
    }
  }
}

void set_initial_state() {
  int[][] initial_state = {
    {0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0}, 
    {2, 7, 0, 1, 7, 0, 1, 7, 0, 1, 7, 0, 1, 1, 1, 1, 2}, 
    {2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2}, 
    {2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 7, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 7, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 7, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 2}, 
    {2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2}, 
    {2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2}, 
    {2, 7, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 2}, 
    {2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2}, 
    {2, 0, 7, 1, 0, 7, 1, 0, 7, 1, 0, 4, 1, 0, 4, 1, 2}, 
    {0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 0}};

  // y coordinate for upper left corner of the initial state
  // centers the initial state within the grid of cells
  int y = area_width / 2 - 10;
  if (area_width % 2 == 1)
    y = ((area_width - 1) / 2) - 10;

  // x coordinate for upper left corner of the initial state
  // centers the initial state within the grid of cells
  int x = area_height / 2 - 5;
  if (area_height % 2 == 1)
    x = ((area_height - 1) / 2) - 5;

  for (int i = 0; i < initial_state.length; i++) {
    for (int j = 0; j < initial_state[i].length; j++) {
      cells[y+j][x+i].set_current_state(initial_state[i][j]);
      cells[y+j][x+i].set_previous_state(initial_state[i][j]);
    }
  }
}

void display_cells(boolean turbo_on) {
  for (int i = 0; i < cells.length; i++) {
    for (int j = 0; j < cells[i].length; j++) {
      cell c = cells[i][j];

      if (c.current_state != c.previous_state || !turbo_on) {
        fill(c.c);
        rect(c.x, c.y, cell_width, cell_width);
      }
    }
  }
}

// main function that transforms the cells to the next state
void transition() {
  // avoid edges, they're missing neighbours
  for (int i = 1; i < cells.length - 1; i++) {
    for (int j = 1; j < cells[i].length - 1; j++) {

      // states of sourrounding cells in VN neighbourhood
      int center = cells[i][j].previous_state;
      int north = cells[i][j-1].previous_state;
      int east = cells[i+1][j].previous_state;
      int south = cells[i][j+1].previous_state;
      int west = cells[i-1][j].previous_state;    

      int new_state = rule_table(center, north, east, south, west);

      if (new_state != -1)
        cells[i][j].set_current_state(new_state);
      else {
        // rotate 4 symmetries
        new_state = rule_table(center, west, north, east, south);
        if (new_state != -1) {
          cells[i][j].set_current_state(new_state);
        } else {

          new_state = rule_table(center, south, west, north, east);
          if (new_state != -1) {
            cells[i][j].set_current_state(new_state);
          } else {

            new_state = rule_table(center, east, south, west, north);
            if (new_state != -1) {
              cells[i][j].set_current_state(new_state);
            } else { 
              // if we are at an edge, set to red to avoid screwing up the whole thing
              //cells[i][j].set_current_state(2);
            }
          }
        }
      }
    }
  }

  if (!turbo) {
    // Have to put here to force synchronicity
    for (int i = 1; i < cells.length - 1; i++) {
      for (int j = 1; j < cells[i].length - 1; j++) {
        cells[i][j].set_previous_state(cells[i][j].current_state);
      }
    }
  }
}

void draw() {
  if (!pause && offset <= 0) {
    display_cells(turbo);

    if (turbo) {
      // Have to put here to force synchronicity
      for (int i = 1; i < cells.length - 1; i++) {
        for (int j = 1; j < cells[i].length - 1; j++) {
          cells[i][j].set_previous_state(cells[i][j].current_state);
        }
      }
    }
    transition();
  } 

  if (offset > 0) {
    offset--;
  }
}

void keyPressed() {
  // transitions by one increment, only works when paused
  if (pause && key == ENTER) {
    display_cells(false);

    for (int i = 1; i < cells.length - 1; i++) {
      for (int j = 1; j < cells[i].length - 1; j++) {
        cells[i][j].set_previous_state(cells[i][j].current_state);
      }
    }

    transition();
  }

  // resets back to initial state
  if (key == TAB) {
    create_cells();
    set_initial_state();

    display_cells(false);
    transition();
  }

  // toggle turbo
  if (key == 't') {
    turbo = !turbo;

    // still works correctly but some cells may show up as wrong colour, fix here
    // don't during pause however, as this will make everything jump forward
    if (!pause)
      display_cells(false);
  }

  // pauses/unpauses
  if (key == 32 /*spacebar*/) {
    pause = !pause;
  }
}

// very ugly, long rule table for transition function, optimised with many nested ifs
// last function in file so reader does not have to scroll down several hundred lines
// tested against a hashmap implementation and was found to be 2-3x faster than hashmap
int rule_table(int center, int north, int east, int south, int west) {
  String table_key = "" + center + north + east + south + west;

  if (!trans_table.containsKey(table_key))
    return -1;

  return trans_table.get(table_key);
}
