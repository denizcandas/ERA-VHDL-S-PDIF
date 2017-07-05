library IEEE;
        use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

entity bpm_tb is
end bpm_tb;

architecture behaviour of bpm_tb is

	component bpm
		port(
			x, y, z, p, data, clk: in std_logic;
			spdif_out: out std_logic
		);
	end component;

signal x: std_logic := '0';
signal y: std_logic := '0';
signal z: std_logic := '0';
signal p: std_logic := '0';
signal data: std_logic := '0';
signal clk: std_logic := '0';
signal spdif_out: std_logic := '0';
constant clk_period : time := 1 ns;

begin
	uut: bpm PORT MAP (
		clk => clk,
		p => p,
		data => data,
		x => x,
		y => y,
		spdif_out => spdif_out,
		z => z
		);
	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	--how long the simulation should continue
	stop_proc: process
	begin
		wait for 256 ns;
		assert false report "Simulation Finished, Exception on Purpose" severity failure;
	end process;

	stim_proc: process
	begin
		wait for clk_period * 1/2;
		--initialize 1st frame
		p <= '0';
		--z-preamble
		x <= '0';
		y <= '0';
		z <= '1';
		data <= '0';
		wait for clk_period * 1;

		--data-fluss
		x <= '0';
		y <= '0';
		z <= '0';
		data <= '1';
		wait for clk_period * 7;
		wait for clk_period * 24;
		data <= '0';
		wait for clk_period * 24;

		--control-bits
		data <= '1';
		wait for clk_period * 6;
		p <= '1'; --paritybit
		wait for clk_period * 2;
		

		--initialize 2nd frame
		p <= '0';
		--y-preamble
		x <= '0';
		y <= '1';
		z <= '0';
		data <= '0';
		wait for clk_period * 1;

		--data-fluss
		x <= '0';
		y <= '0';
		z <= '0';
		data <= '1';
		wait for clk_period * 7;
		wait for clk_period * 24;
		data <= '0';
		wait for clk_period * 24;

		--control-bits
		data <= '1';
		wait for clk_period * 6;
		p <= '1'; --paritybit
		wait for clk_period * 2;		


		--initialize 3rd frame
		p <= '0';
		--x-preamble
		x <= '1';
		y <= '0';
		z <= '0';
		data <= '0';
		wait for clk_period * 1;

		--data-fluss
		x <= '0';
		y <= '0';
		z <= '0';
		data <= '1';
		wait for clk_period * 7;
		wait for clk_period * 24;
		data <= '0';
		wait for clk_period * 24;

		--control-bits
		data <= '1';
		wait for clk_period * 6;
		p <= '1'; --paritybit
		wait for clk_period * 2;		


		--initialize 4th frame
		p <= '0';
		--y-preamble
		x <= '0';
		y <= '1';
		z <= '0';
		data <= '0';
		wait for clk_period * 1;

		--data-fluss
		x <= '0';
		y <= '0';
		z <= '0';
		data <= '1';
		wait for clk_period * 7;
		wait for clk_period * 24;
		data <= '0';
		wait for clk_period * 24;

		--control-bits
		data <= '1';
		wait for clk_period * 6;
		p <= '1'; --paritybit
		wait for clk_period * 2;

	end process;
end;
