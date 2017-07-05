library IEEE;
        use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

entity BPM is
	port(
		x, y, z, p, data, clk: in std_logic;
		spdif_out: out std_logic
	);
end BPM;

architecture bpm of BPM is
	signal zustand: unsigned(5 downto 0);
	
begin
	process(clk)
	begin
		if rising_edge(clk) then
			--Die folgenden Faelle behandeln alle die Weiterleitung der an 
			--Data anliegenden Werte
			if zustand = 0 then
				if data = '0' then
					zustand <= to_unsigned(1,6);
				else
					zustand <= to_unsigned(2,6);
				end if;
			elsif zustand = 1 then
				if p = '0' then
					zustand <= to_unsigned(0,6);
				else
					zustand <= to_unsigned(4,6);
				end if;
			elsif zustand = 2 then
				if p = '0' then
					zustand <= to_unsigned(3,6);
				else 
					zustand <= to_unsigned(5,6);
				end if;
			elsif zustand = 3 then
				if data = '1' then 
					zustand <= to_unsigned(2,6);
				else
					zustand <= to_unsigned(1,6);
				end if;
			--Die folgenden Faelle sind fuer die Generierung des Parity-Bits 
			--verantwortlich
			elsif zustand = 4 or zustand = 5 then
				zustand <= to_unsigned(6,6);
			--tritt einer der drei folgenden Faelle auf, befinden wir uns
			--(unter Annahme gueltiger Eingaben) stets in Zustand 6 oder am Programmstart
			--Aus dieser Deklaration folgt: die Zustaende 7-18 entsprechen der Ausgabe der Preambel X,
			--die Zustaende 19-30 der von Y, und 31-42 der von Z
			elsif x = '1' then
				zustand <= to_unsigned(7,6);
			elsif y = '1' then
				zustand <= to_unsigned(19,6);
			elsif z = '1' then
				zustand <= to_unsigned(31,6);
			--falls die Ausgabe einer jeweiligen Preambel zu Ende geht
			elsif zustand = 18 or zustand = 30 or zustand = 42 then
				zustand <= to_unsigned(3,6);
			--alle Faelle, bei denen bei einer Preambel ein Uebergang von '1' auf '0'
			--oder von '0' auf '1' auftritt
			elsif zustand = 11 or zustand = 16 or zustand = 17 or zustand = 24 or zustand = 26
			or zustand = 27 or zustand = 35 or zustand = 36 or zustand = 37 then
				zustand <= zustand + to_unsigned(1,6);
			--alle Faelle, bei denen bei einer Preambel der Wert des letzten Taktes mit dem
			--Wert des neuen Taktes uebereinstimmt
			else 
				zustand <= zustand + to_unsigned(2,6);
			end if;
			--zur Erklaerung der Werte, die die Preambeln annehmen; laut den Richtlinien
			--in der Spezifikation ist die Ausgabe = zustand mod 2.
			--Das muss auch fuer alle die Zustaende gelten, bei denen wir eine Preambel ausgeben.
			--Zum Beispiel: die Ausgabe von X.
			--Das 1. Bit der Preambel X ( X(0) ) ist '1'. Der Zustand ist laut Definition 7 ( Z(X(0)) = 7 ).
			--X(1) = '1', also muss der naechste Zustand auch ungerade sein. Damit ist Z(X(1)) = 9
			--X(2) = '1', Z(X(2)) = 11.
			--X(3) = '0', d.h. der naechste Zustand muss gerade sein. Wir waehlen den naechsten Wert nach
			--11, der gerade ist, also 12. Z(X(3)) = 12.
			--Im Allgemeinen gilt also: aendert sich der Zustand zwischen X(i) und X(i-1) nicht,
			--deklarieren wir einen Zustand Z(X(i)), sodass gilt: Z(X(i)) mod 2 = Z(X(i-1)) mod 2
			--Da wir fuer die Lesbarkeit des Programms wollen, dass ein Zustand fuer ein hoehergelegenes Bit
			--auch groesser als die vorhergegangen Zustaende ist, und andererseits wollen, dass der Unterschied
			--zwischen der Zahl zweier aufeinanderfolgender Zustaende moeglichst klein ist, damit wir moeglichst wenige
			--Bits fuer das Signal zustand benoetigen, deklarieren wir Z(X(i)) = Z(X(i-1)) + 2
			--aendert sich dagegen der Zustand zwischen X(i) und X(i-1), kann einfach der
			--darauffolgende Zustand gewaehlt werden.
			
		end if;		
	end process;
	spdif_out <= zustand(0);
end bpm;
