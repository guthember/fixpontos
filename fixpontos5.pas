{
   * CHDGC8 Gúth Erik Zoltán
   *
   * Copyright 2016 Erik <Erik@erik-pc>
   * 
   * 5. feladat
   * Készíts nagypontosságú fixpontos valós aritmetikai modult 
   * (felhasználva a nagypontosságú egész aritmetikát): 
   * 
   * összeadás, kivonás, osztás!
}

program fixpontos5;

uses
	FixUnit, SysUtils, Video;
	
var
	vSzam1, vSzam2 : ValosSzam;
	szam : string;
	
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
	ClearScreen();
	Ismerteto();
	Elvalaszto();
	Beker('Kerem az elso szamot: ',szam);
	if( not (Ellenoriz(szam) ) ) then
	begin
		writeln('Rossz a megadás!');
		exit;
	end;
	Szetszed(szam, vSzam1);
	Beker('Kerem a masodik szamot: ',szam);
	if( not (Ellenoriz(szam) ) ) then
	begin
		writeln('Rossz a megadás!');
		exit;
	end;
	Szetszed(szam, vSzam2);
	Elvalaszto();
	if ( not (KozosSzamrendszer(vSzam1, vSzam2) ) ) then
	begin
		writeln('Nem kozos a szamrendszer, hiba!');
		exit;
	end;
	writeln('Elso    szam:',ValKiir(vSzam1));
	writeln('Masodik szam:',ValKiir(vSzam2));
{	writeln('Amit megadtal: ',szam);
	if( Ellenoriz(szam)  = false ) then
	begin
		writeln('Rossz a szam');
	end
	else
	begin
		writeln('Jo a szam');
		Szetszed(szam, vSzam);
		writeln(ValKiir(vSzam));
		writeln('Szamrendszer: ',vSzam.szamrendszer);
		writeln('Egeszresz: ',vSzam.egesz.jegy);
		writeln('Hossza   : ',vSzam.egesz.hossz);
		writeln('Tortresz: ',vSzam.tort.jegy);
		writeln('Hossza   : ',vSzam.tort.hossz);
		if( not Pozitiv(vSzam) )then
		begin
			writeln('Negativ szam');
		end
		else
		begin
			writeln('Pozitiv szam');
		end;
	end;
}

END.

