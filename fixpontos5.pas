{
   * CHDGC8 Gúth Erik Zoltán
   *
   * 5. feladat
   * Készíts nagypontosságú fixpontos valós aritmetikai modult 
   * (felhasználva a nagypontosságú egész aritmetikát): 
   * 
   * összeadás, kivonás, osztás!
}

program fixpontos5;

uses
	FixUnit, SysUtils;
	
var
	vSzam : ValosSzam;

var
	szam : string;
	egesz : integer;
BEGIN
{
// 	ez működött
	writeln('Hello vilag');
	writeln(Szamjegy(10));
	writeln(ValSzamjegy('9'));
	readln(szam);
	writeln(szam);
	if( (Pos('0',szam)=1) and (Length(szam) > 1) ) then
	begin
		writeln('Vezeto nulla');
		szam := VezetoNullakElt(szam, Length(szam));
		egesz := StrToInt(szam);
		writeln(2*egesz);
	end
	else
	begin
		writeln('Nincs vezeto nulla');
	end;
}	
	Ismerteto();
	Beker('Kerek egy fixpontos szamot: ',szam);
	writeln('Amit megadtal: ',szam);
END.

