test:
	./ghdl -a VHDL_Implementierung.vhdl
	./ghdl -e bpm
	./ghdl -a bpm_tb.vhdl
	./ghdl -e bpm_tb
	./ghdl -r bpm_tb --vcd=bpm_tb.vcd

