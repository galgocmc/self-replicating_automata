class cell {
  int x, y;
  private int previous_state, current_state;
  color c;

  public cell(int x, int y) {
    this.x = x;
    this.y = y;

    previous_state = 0;
    current_state = 0;
    c = color(0);
  }

  public cell(int x, int y, int current_state) {
    this.x = x;
    this.y = y;

    previous_state = current_state;
    this.current_state = current_state;
    c = get_colour(current_state);
  }

  int get_previous_state() {
    return previous_state;
  }

  void set_current_state(int state) {
    current_state = state;
    c = get_colour(state);
  }


  void set_previous_state(int state) {
    previous_state = state;
  }

  int get_current_state() {
    return current_state;
  }

  private color get_colour(int state) {
    if (state == 0) return color(0); //black
    if (state == 1) return color(0, 0, 255); // blue
    if (state == 2) return color(255, 0, 0); // red
    if (state == 3) return color(0, 255, 0); // green
    if (state == 4) return color(255, 255, 0); // yellow
    if (state == 5) return color(255, 105, 180); // pink
    if (state == 6) return color(255, 255, 255); // white
    return color(0, 255, 255); // if state=7 cyan
  }
}
