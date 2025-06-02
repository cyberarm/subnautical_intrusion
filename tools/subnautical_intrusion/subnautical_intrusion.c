#include <mruby.h>
#include <mruby/compile.h>

#ifdef MRB_NO_STDIO
#error mruby-bin-mirb conflicts 'MRB_NO_STDIO' in your build configuration
#endif

#include <stdlib.h>

int main(int argc, char **argv)
{
  mrb_state *mrb;

  mrb = mrb_open();
  if (mrb == NULL)
  {
    puts("FAILED TO INIT");
    fputs("Invalid mrb interpreter, exiting mirb\n", stderr);
    return EXIT_FAILURE;
  }

  mrb_load_string(mrb, "SubnauticalIntrusion::Window.new(width: 1280, height: 800, resizable: true).show");

  mrb_close(mrb);

  return 0;
}
