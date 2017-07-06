--standard libraries used for simple comparisons and vectors
library IEEE;
        use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

--name of the entity
entity bpm_tb is
end bpm_tb;

--start of architecture
architecture behaviour of bpm_tb is
	
	--name of the entity that is being tested, it was created using VHDL_Implementierung.vhdl
	component bpm
		port(
	--x, y, z, p are signals that are sent by the Timing Generator; data is sent from the Data-Multiplexer and is ignored if any signal from the Timing Generator is 1, spdif_out is the S/PDIF output and the clock is two times faster than the incoming data
			x, y, z, p, data, clk: in std_logic;
			spdif_out: out std_logic
		);
	end component;

--initialization of all signals to avoid unexpected behaviour
signal x: std_logic := '0';
signal y: std_logic := '0';
signal z: std_logic := '0';
signal p: std_logic := '0';
signal data: std_logic := '0';
signal clk: std_logic := '0';
signal spdif_out: std_logic := '0';
constant clk_period : time := 1 ns;
--frame is an unsigned vector that holds current frame in a block; it is set to reset when it reaches 192 and is used by the test case to generate random data and to generate the correct preamble signal
signal frame: unsigned(7 downto 0) := "00000000";

--beginning of architecture
begin
	--testbench initialization
	uut: bpm PORT MAP (
		clk => clk,
		p => p,
		data => data,
		x => x,
		y => y,
		spdif_out => spdif_out,
		z => z
		);

	--the clock, which as stated in task is twice as fast as input
	clk_process: process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	--which frame the subcode data stream is currently at (a frame is 64 ticks long)
	frame_process: process
	begin
		frame <= frame + 1;
		--if the end of a block is reached, frame is reset
		if frame = 192 then
			frame <= "00000000";
		end if;
		--a frame is 64 ticks long
		wait for clk_period * 64;
	end process;

	--this process simulates an incoming frame
	stim_process: process
	begin
		--initialize 1st frame (left frame)
		if frame = "00000000" then
			p <= '0';
			--z-preamble
			x <= '0';
			y <= '0';
			z <= '1';
			wait for clk_period * 1;
			x <= '0';
			y <= '0';
			z <= '0';
			wait for clk_period * 7;

			--data-flow
			wait for clk_period * 48;

			--control-bits
			wait for clk_period * 6;
			p <= '1'; --paritybit
			wait for clk_period * 2;

		--initialize x frame (left frame)
		elsif frame(0) = '0' then
			p <= '0';
			--x-preamble
			x <= '1';
			y <= '0';
			z <= '0';
			wait for clk_period * 1;
			x <= '0';
			y <= '0';
			z <= '0';
			wait for clk_period * 7;

			--data-flow
			wait for clk_period * 48;

			--control-bits
			wait for clk_period * 6;
			p <= '1'; --paritybit
			wait for clk_period * 2;

		--initialize y frame (right frame)
		elsif frame(0) = '1' then
			p <= '0';
			--y-preamble
			x <= '0';
			y <= '1';
			z <= '0';
			wait for clk_period * 1;
			x <= '0';
			y <= '0';
			z <= '0';
			wait for clk_period * 7;

			--data-flow
			wait for clk_period * 48;

			--control-bits
			wait for clk_period * 6;
			p <= '1'; --paritybit
			wait for clk_period * 2;
		end if;
	end process;

	--this process reassigns data constantly in a random-like fashion
	data_process: process
	begin
	if data = '0' then
		data <= '1';
	else
		data <= '0';
	end if;
	wait for 2 * (to_integer(frame) + 1) * clk_period;
	end process;
end;
