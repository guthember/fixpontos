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
	sysutils;

const 
	SZAMSOROZAT = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	
{
* neve: Szamjegy 
* paraméter: i (egész)
* visszatérés: sztring
* visszadja a számjegynek megfelelő sztringet
* }
function Szamjegy(const i : integer): string;
begin
	Szamjegy := Copy(SZAMSOROZAT,i+1,1);
end;

{
* neve: ValSzamjegy 
* paraméter: s (string)
* visszatérés: egész
* visszadja a számjegynek megfelelő egész értéket
* }
function ValSzamjegy(const s : string):integer;
begin
	ValSzamjegy := Pos(s,SZAMSOROZAT )-1;
end;

{
* neve: VezetoNullakElt 
* paraméter: szam (string), hossz (egész)
* visszatérés: string
* vezető nullákat eltávolítja a sztringből
* }
function VezetoNullakElt(const szam : string; const hossz : integer) : string;
var
	ujSzam : string;
	ujHossz : integer;
begin
	ujSzam := szam;
	ujHossz := hossz;
	// amíg van vezető nulla és a hossz nagyobb mint 1
	while ( (Pos('0',ujSzam) = 1) and (ujHossz > 1) ) do
	begin
		ujSzam := Copy(ujSzam,2,ujHossz-1);
		dec(ujHossz);
	end;
	VezetoNullakElt := ujSzam;
end;

var
	szam : string;
	egesz : integer;
BEGIN
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
	
END.

