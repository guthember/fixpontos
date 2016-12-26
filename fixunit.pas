{
   FIXUNIT.pas
   
   Copyright 2016 Erik <Erik@erik-pc>
   
   CHDGC8 Gúth Erik Zoltán
   * 
   
}

Unit FixUnit;

Interface

{$mode objfpc}

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
	procedure Beker(const kiir: string; var szam : string);
	procedure Szetszed(const szam : string; var valos : ValosSzam);
	function Ellenoriz(const szam : string) : boolean;
	function Szamjegy(const i : integer): string;
	function ValSzamjegy(const s : string):integer;
	function VezetoNullakElt(const szam : string; const hossz : integer) : string;
	function Pozitiv(const vSzam : ValosSzam): boolean;

Implementation

{
* neve: Ellenoriz 
* parameter: szam (string)
* visszatérés: boolean
* ha jó a szám akkor igaz, ha nem akkor hamis
* }
function Ellenoriz(const szam : string) : boolean;
const
	JOK = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ+-(),';
var
	i         : integer;
	nyit, zar : integer; // zárójelek
	vesszo    : integer; // hol van a tizedes vessző
	szamr	  : integer; // mennyi a számrendszer
	szamrSz   : string;
	kezdo     : integer; // ahol a számjegyek kezdődnek
	egesz     : string;
	tort      : string;
begin
	for i := 1 to Length(szam) do
	begin   
		// ha nem megengedett karakterek vannak benne
		if ( (Pos(szam[i],JOK) = 0 ) ) then
		begin
			Ellenoriz := false;
			break;
		end
		else
		// elvileg jók a karakterek csak
		begin
			// nem jó helyen van az előjeljegy
			if ( ((szam[i] = '+') or (szam[i] = '-') ) and ( i > 1) ) then
			begin
				Ellenoriz := false;
				break;
			end;
		end;
	end;

	vesszo := Pos(',',szam);
	// van benne tizedes vessző
	if ( vesszo > 0 ) then
	begin
		// ha több vessző is van benne
		if( vesszo <> LastDelimiter(',',szam))then
		begin
			Ellenoriz := false;
			exit;
		end;
		if( vesszo = 1 ) then
		begin
			Ellenoriz := false;
			exit;
		end;
	end;

	nyit := Pos('(',szam);
	zar  := Pos(')',szam);
	
	// nem párosával vannak
	if( (nyit = 0) and (zar > 0))then
	begin
		Ellenoriz := false;
		exit;
	end;
	if ( (nyit > 0) and (zar = 0 )) then
	begin
		Ellenoriz := false;
		exit;
	end;
	
	// van benne számrendszer megadás
	if ( nyit > 0 ) then
	begin
		// ha rossz helyen van a tizedes vessző
		if( nyit < vesszo ) then
		begin
			Ellenoriz := false;
			exit;
		end;
		if (nyit = 1) then
		begin
			Ellenoriz := false;
			exit;
		end;
		// több nyitójel van benne
		if( nyit <> LastDelimiter('(',szam) ) then
		begin
			Ellenoriz := false;
			exit;
		end;
		zar := Pos(')', szam);
		// több zárójel van benne
		if( zar <> LastDelimiter(')',szam) )then
		begin
			Ellenoriz := false;
			exit;
		end;
		// ha előrébb van a záró vagy nincs benne
		if ( (zar < nyit) or ( zar = 0 ) ) then
		begin
			Ellenoriz := false;
			exit;
		end;
		
		// ha a zárójelek jók de nem lehet legelöl vagy közvetlen +/- után
		if( ((szam[1] ='+' ) or (szam[1] = '-')) and (nyit = 2) ) then
		begin
			Ellenoriz := false;
			exit;
		end;
	
		szamrSz := Copy( szam, nyit+1,zar-nyit-1);
		writeln('szamrendszer = ',szamrSz);
		Try
			szamr := StrToInt(szamrSz);
		except
			On E : EConvertError do
			begin
				Ellenoriz := false;
				exit;
			end;
		end;

		// jó-e a számrendszer?
		if( (szamr < 2) or (szamr > 35) ) then
		begin
			Ellenoriz := false;
			exit;
		end;
	end
	else
	// tizes számrendszerben van
	begin
		szamr := 10;
	end;

	// ha  minden jó akkor meg kell nézni, hogy a számrendszernek megfelelő
	// számjegyek vannak benne
	if( (szam[1] = '+') or (szam[1] = '-') ) then
	begin
		kezdo := 2;
	end
	else
	begin
		kezdo := 1;
	end;
	
	// ha van megadva tizedes vesszo
	if ( vesszo > 0 ) then
	begin
		egesz := Copy(szam, kezdo, vesszo - kezdo);
		// ha nincs benne számrendszer megadás
		if ( nyit = 0 ) then
		begin
			tort := Copy(szam, vesszo +1, Length(szam)-vesszo+1);
		end
		else
		begin
			tort := Copy(szam, vesszo + 1, nyit - vesszo - 1);
		end;
	end
	else
	begin
		// ha nincs benne számrendszer megadás
		if ( nyit = 0 )then
		begin
			egesz := Copy(szam, kezdo, Length(szam) - kezdo+1);
		end
		else
		begin
			egesz := Copy(szam, kezdo, nyit - kezdo);
		end;
		tort := '0';
	end;
	writeln('Egesz: ',egesz);
	writeln('Tort: ', tort);

	// számjegyek ellenőrzése
	for i := 1 to Length(egesz) do
	begin
		if( ValSzamjegy(egesz[i]) >= szamr )then
		begin
			Ellenoriz := false;
			exit;
		end;
	end;
	if( Length(tort)>= 1) then
	begin
		for i:= 1 to Length(tort) do
		begin
			if( ValSzamjegy(tort[i]) >= szamr ) then
			begin
				Ellenoriz := false;
				exit;
			end;
		end;
	end;
end;

{
* neve: Pozitiv 
* parameter: vSzam (valós)
* visszatérés: boolean
* ha pozitív a szám akkor igaz, ha negatív akkor hamis
* }
function Pozitiv(const vSzam : ValosSzam): boolean;
begin
	if( vSzam.egesz.elojel = Poz) then
	begin
		Pozitiv := true;
	end
	else
	begin
		Pozitiv := false;
	end;
end;

procedure Szetszed(const szam : string; var valos : ValosSzam);
begin

	// Előjel beállítása
	if( (szam[1] = '+') or (szam[1] = '-') )then
	begin
		if( szam[1] = '+') then
		begin
			valos.egesz.elojel := Poz;
		end
		else
		begin
			valos.egesz.elojel := Neg;
		end;
	end
	else
	begin
		valos.egesz.elojel := Poz;
	end; 	
end;

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
	writeln('		Vezeto tizedes vesszo nem lehet!');
	writeln('		Legalabb egy nullat egeszresznek meg kell adni! pl.: 0,12');
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
* egy stringet kére be a megfelelő kiirással
* nagybetűssé is alakítja
* }
procedure Beker(const kiir: string; var szam : string);
begin
	write(kiir);
	readln(szam);
	szam := UpperCase(szam);
end;


begin
end.
