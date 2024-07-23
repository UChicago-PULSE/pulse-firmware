`timescale 1 ms / 100 ns

module testbench1(); // Testbench has no inputs, outputs
  reg t_CLK_16MHZ;    // 16MHz clock
  wire t_USBPU;
  wire t_LED;

  wire t_output_signal;
  wire t_output_clock;
  wire t_output_CS;
  wire t_IO0;
  reg t_IO1;
  reg t_begin_send;

  // instantiate device under test
  top test_top_module (
      .CLK_16MHZ(t_CLK_16MHZ),    // 16MHz clock
      .USBPU(t_USBPU),  // USB pull-up resistor
      .LED(t_LED),

      .output_signal(t_output_signal),
      .output_clock(t_output_clock),
      .output_CS(t_output_CS),
      .IO0(t_IO0),
      .IO1(t_IO1),
      .begin_send(t_begin_send)
  );

  // apply inputs one at a time
  initial begin // sequential block
    $dumpfile("testbench_TB.vcd");
    $dumpvars;

    t_IO1 = 1'b0;

    t_begin_send = 0;
    #35

    t_begin_send = 1;
    #50

    t_begin_send = 0;
    #100

    $finish;
  end

  always begin
    t_CLK_16MHZ = 0; #0.00025;
    t_CLK_16MHZ = 1; #0.00025;
  end

endmodule
