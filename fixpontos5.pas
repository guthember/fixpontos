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
	szam           : string;
BEGIN
	ClearScreen();
	Ismerteto();
	Elvalaszto();
	Beker('Kerem az elso szamot  : ',szam);
	if( not (Ellenoriz(szam) ) ) then
	begin
		writeln('Rossz a megadas!');
		exit;
	end;
	Szetszed(szam, vSzam1);
	Beker('Kerem a masodik szamot: ',szam);
	if( not (Ellenoriz(szam) ) ) then
	begin
		writeln('Rossz a megadas!');
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
	
	Elvalaszto();
	if ( VEgyenlo(vSzam1, vSzam2)) then
	begin
		writeln(ValKiir(vSzam1),' = ',ValKiir(vSzam2));
	end
	else
	begin
		if ( VNagyobb(vSzam1, vSzam2) ) then
		begin
			writeln(ValKiir(vSzam1),' > ',ValKiir(vSzam2));
		end
		else
		begin
			writeln(ValKiir(vSzam1),' < ',ValKiir(vSzam2));
		end;
	end;
	Elvalaszto();
	writeln('Osszeguk   :',VOsszead(vSzam1,vSzam2));
	Elvalaszto();
	writeln('Kulonbseguk:',VKivon(vSzam1,vSzam2));
END.

