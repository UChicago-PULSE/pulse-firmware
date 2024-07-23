`ifndef SLOW_CLOCK

module Clock_16MHZ_to_10MHZ_converter (CLK_16MHZ_Input, CLK_10MHZ_Output);
  input CLK_16MHZ_Input;
  output CLK_10MHZ_Output;

  SB_PLL40_CORE usb_pll_inst (
    .REFERENCECLK(CLK_16MHZ_Input),
    .PLLOUTCORE(CLK_10MHZ_Output),
    .RESETB(1),
    .BYPASS(0)
  );

  // Fin=16, Fout=10;
  defparam usb_pll_inst.DIVR = 0;
  defparam usb_pll_inst.DIVF = 9;
  defparam usb_pll_inst.DIVQ = 4;
  defparam usb_pll_inst.FILTER_RANGE = 3'b001;
  defparam usb_pll_inst.FEEDBACK_PATH = "SIMPLE";
  defparam usb_pll_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
  defparam usb_pll_inst.FDA_FEEDBACK = 4'b0000;
  defparam usb_pll_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
  defparam usb_pll_inst.FDA_RELATIVE = 4'b0000;
  defparam usb_pll_inst.SHIFTREG_DIV_MODE = 2'b00;
  defparam usb_pll_inst.PLLOUT_SELECT = "GENCLK";
  defparam usb_pll_inst.ENABLE_ICEGATE = 1'b0;

endmodule

`endif
