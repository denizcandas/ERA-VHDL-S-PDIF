# You can change the stream length here (A block has 192 frames, which are 64 ticks long)
# 1 Frame = 64, 1 Block = 192 * 64 = 12288
StreamLength = 12288


test:
	ghdl -a VHDL_Implementierung.vhdl
	ghdl -e bpm
	ghdl -a bpm_tb.vhdl
	ghdl -e bpm_tb
	ghdl -r bpm_tb --stop-time=$(StreamLength)ns --vcd=bpm_tb.vcd
	gtkwave bpm_tb.vcd
