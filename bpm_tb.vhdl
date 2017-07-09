--Standard Libraries
library IEEE;
        use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

--The name of our component, stands for Biphase-Mark Encoder
entity bpm_tb is
end bpm_tb;

--Start of architecture
architecture behaviour of bpm_tb is

	--Signals of our main entity, as defined in VHDL_Implementierung.vhdl
	component bpm
		port(
			x, y, z, p, data, clk: in std_logic;
			spdif_out: out std_logic
		);
	end component;

--Initialization of all signals to avoid META-Data von GTKWave and unexpected behaviour
--Signals as specified in the task
signal x: std_logic := '0';
signal y: std_logic := '0';
signal z: std_logic := '0';
signal p: std_logic := '0';
signal data: std_logic := '0';
--The clock, which is twice as fast as incoming data
signal clk: std_logic := '0';
constant clk_period : time := 1 ns;
--The S/PDIF output
signal spdif_out: std_logic := '0';
--The current frame. Every block has 192 frames. A frame is composed of two subframes and each subframe holds 32 bits of data, but it takes 64 ticks of our clock to actually analyze it (while the clock is twice as fast).
signal frame: unsigned(7 downto 0) := "00000000";

begin
	--UUT: Unit Under Test, the port map of our benchmark
	uut: bpm PORT MAP (
		clk => clk,
		p => p,
		data => data,
		x => x,
		y => y,
		spdif_out => spdif_out,
		z => z
		);

	--Our clock, which as stated in task is twice as fast as input
	clk_process: process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	--Which frame we are currently at
	frame_process: process
	begin
		frame <= frame + 1;
		--Frame is reset at the end of each block, a block is 192 frames long
		if frame = 192 then
			frame <= "00000000";
		end if;
		--Each frame is 128 ticks long
		wait for clk_period * 128;
	end process;

	stim_process: process
	begin
		--Initialize 1st frame
		if frame = "00000000" then
			p <= '0';
			--z-Preamble
			x <= '0';
			y <= '0';
			z <= '1';
			wait for clk_period * 1;
			x <= '0';
			y <= '0';
			z <= '0';
			wait for clk_period * 7;

			--Data-flow
			wait for clk_period * 48;

			--Control-Bits
			wait for clk_period * 6;
			p <= '1'; --Parity-Bit
			wait for clk_period * 2;

			--initialize following subframe
			p <= '0';
			--y-Preamble
			x <= '0';
			y <= '1';
			z <= '0';
			wait for clk_period * 1;
			x <= '0';
			y <= '0';
			z <= '0';
			wait for clk_period * 7;

			--Data-flow
			wait for clk_period * 48;

			--Control-Bits
			wait for clk_period * 6;
			p <= '1'; --Parity-Bit
			wait for clk_period * 2;

		--Initialize other frames
		else
			p <= '0';
			--x-Preamble
			x <= '1';
			y <= '0';
			z <= '0';
			wait for clk_period * 1;
			x <= '0';
			y <= '0';
			z <= '0';
			wait for clk_period * 7;

			--Data-flow
			wait for clk_period * 48;

			--Control-Bits
			wait for clk_period * 6;
			p <= '1'; --Parity-Bit
			wait for clk_period * 2;

		--Initialize following subframe
			p <= '0';
			--y-Preamble
			x <= '0';
			y <= '1';
			z <= '0';
			wait for clk_period * 1;
			x <= '0';
			y <= '0';
			z <= '0';
			wait for clk_period * 7;

			--Data-flow
			wait for clk_period * 48;

			--Control-Bits
			wait for clk_period * 6;
			p <= '1'; --Parity-Bit
			wait for clk_period * 2;
		end if;
	end process;

	--Random data generation
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
