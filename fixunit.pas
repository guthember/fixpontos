{
   FIXUNIT.pas
   
   Copyright 2016 Erik <Erik@erik-pc>
   
   CHDGC8 Gúth Erik Zoltán
   * 
   
}

Unit FixUnit;

Interface

uses 
	sysutils;

const 
	SZAMSOROZAT  = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	MAXPONTOSSAG = 200;
	
type
	Szamj            = Byte;
	ElojelTipus      = (Poz,Neg);
	PontossagTipus   = 0..MAXPONTOSSAG;
	SzamrendszerTipus= 2..35;
	PozSzam          = Array[0..MAXPONTOSSAG] of Szamj;
	EgeszSzam        = Record
                         elojel      : ElojelTipus;
						 hossz       : PontossagTipus;
						 szamrendszer: SzamrendszerTipus;
						 jegy        : PozSzam;
					   End;
	ValosSzam		 = Record
						 egesz, tort : EgeszSzam;
					   End;

	procedure Ismerteto();
	function Szamjegy(const i : integer): string;
	function ValSzamjegy(const s : string):integer;
	function VezetoNullakElt(const szam : string; const hossz : integer) : string;
	procedure Beker(const kiir: string; var szam : string);
Implementation

{
* neve: Ismerteto 
* parameter: nincs
* a programról kiírja az ismertetőt
* }
procedure Ismerteto();
begin
	writeln('Fixpontos szamokkal vegzett muveletek');
	writeln('A szam megadasa a kovetkezo kepen lehetseges:');
	writeln('	Az elojel megadasa :[+/-], ha semmi akkor az alapertelmezetten pozitiv.');
	writeln(' 	Egesz resz:');
	writeln('		Szamok megadasa:[0..Z], a szamrendszernek megfelelo szamjegyek.');
	writeln('	Tizedes vesszo: ,');
	writeln('	Tort resz:');
	writeln('		Szamok megadasa:[0..Z], a szamrendszernek megfelelo szamjegyek.');
end;

{
* neve: Szamjegy 
* parameter: i (egész)
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

{
* neve: Beker 
* paraméter: kiir (string), szam (string)
* egy stringet kére be a megfelelő kiiárással
* }
procedure Beker(const kiir: string; var szam : string);
begin
	write(kiir);
	readln(szam);
end;


begin
end.
