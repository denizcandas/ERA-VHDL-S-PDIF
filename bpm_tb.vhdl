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
signal frame: unsigned(7 downto 0) := "00000000";

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

	--our clock, which as stated in task is twice as fast as input
	clk_process: process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	--which frame we are currently at
	frame_process: process
	begin
		frame <= frame + 1;
		if frame = 192 then
			frame <= "00000000";
		end if;
		wait for clk_period * 64;
	end process;

	stim_process: process
	begin
		--initialize 1st frame
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

		--initialize x frame
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

		--initialize y frame
		elsif frame(0) = '1' then
			p <= '0';
			--x-preamble
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
