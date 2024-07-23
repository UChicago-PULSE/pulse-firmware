`define true 1'b1
`define false 1'b0

`define SLOW_CLOCK

module top(CLK_16MHZ, USBPU, LED, output_signal, output_clock, output_CS, IO0, IO1, begin_send);
  input CLK_16MHZ; //input CLK_16MHZ;    // 16MHz clock
  output USBPU;  // USB pull-up resistor
  output reg LED = 0;

  output output_signal;
  output output_clock;
  output output_CS;
  output IO0;
  input IO1;
  input begin_send;

  // drive USB pull-up resistor to '0' to disable USB
  assign USBPU = 0;

// ---------- CLOCK GENERATION ----------

  wire internal_clk_wire; // internal clock at 10 MHz

`ifndef SLOW_CLOCK

  Clock_16MHZ_to_10MHZ_converter clock_conv_inst (
    .CLK_16MHZ_Input(CLK_16MHZ),
    .CLK_10MHZ_Output(internal_clk_wire)
  );

`else

  reg clock_8khz_wire = 0;
    reg [22:0] clk_8khz_counter = 23'b0;  // 8 kHz clock
    always @(posedge CLK_16MHZ) begin
      if (clk_8khz_counter < 23'd0_999)
         clk_8khz_counter = clk_8khz_counter + 23'b1;
      else begin
         clk_8khz_counter = 23'b0;
         clock_8khz_wire = ~clock_8khz_wire;
      end
   end
  assign internal_clk_wire = clock_8khz_wire;

`endif

// ---------- FLASH MEMORY LOGIC ----------

  reg block_outputs = 1'b1;
  reg internal_cs_wire = 1'b1;
  reg internal_output_wire = 1'b0;
  reg internal_instruction_wire = 1'b0;

  integer process_step = 0;
  integer process_substep = 8;

  reg[7:0] instruction = 8'b00001011;

  assign {output_CS,        output_clock,      output_signal,        IO0} = block_outputs ?
         {1'bz,             1'bz,              1'bz,                 1'bz} :
         {internal_cs_wire, internal_clk_wire, internal_output_wire, internal_instruction_wire};

always @(begin_send) begin
  if (begin_send === 1'b1) begin
    if (process_step === 0) begin
      block_outputs = 0; LED = 1;
    end else begin ; end
  end else if (begin_send === 1'b0) begin
    if (process_step !== 0) begin
      block_outputs = 1; LED = 0;
    end else begin ; end
  end else begin ; end
end

always @(negedge internal_clk_wire) begin
    if (begin_send === 1'b1) begin
      if (process_step === 0) begin
        process_step = 1;
        process_substep = 3; //TODO: change
        internal_cs_wire = 1;
        internal_output_wire = 0;
      end else begin ; end
    end else if (begin_send === 1'b0) begin
      if (process_step !== 0) begin
        process_step = 0;
        process_substep = 8;
        internal_cs_wire = 1;
        internal_output_wire = 0;
      end else begin ; end
    end else begin ; end

    if (begin_send === 1'b1) begin
      case (process_step)
        1 : begin
              if (process_substep === 0) begin
                  process_step = 2;
                  process_substep = 7;
                  internal_cs_wire = 1'b0;
                  internal_instruction_wire = 1'b0;
              end else begin
                process_substep = process_substep - 1;
              end
            end
        2 : begin
              internal_instruction_wire = instruction[process_substep-1];
              if (process_substep === 0) begin
                  process_step = 3;
                  process_substep = 7;
                  internal_instruction_wire = 1'b0;
              end else begin
                process_substep = process_substep - 1;
              end
            end
        3 : begin
              internal_instruction_wire = 1'b0;
              if (process_substep === 0) begin
                  process_step = 4;
                  process_substep = 7;
                  internal_instruction_wire = 1'bz;
              end else begin
                process_substep = process_substep - 1;
              end
            end
        4 : begin
              internal_instruction_wire = 1'bz;
              if (process_substep === 0) begin
                  process_step = 5;
                  process_substep = 255; //134217728
                  internal_output_wire = IO1;
              end else begin
                process_substep = process_substep - 1;
              end
            end
        5 : begin
              internal_output_wire = IO1;
              if (process_substep === 0) begin
                  process_step = 6;
                  process_substep = 0;
                  internal_cs_wire = 1;
              end else begin
                process_substep = process_substep - 1;
              end
            end
        default : ;
      endcase
    end else begin ; end
  end

endmodule
