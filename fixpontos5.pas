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

const
	TESZT_FILE = 'tesztkiir.txt';
	ADAT_FILE  = 'adat.txt';

	
var
	tfOut          : text;
	tfIn		   : text;
	vSzam1, vSzam2 : ValosSzam;
	szam           : string;
	valaszt        : string;
BEGIN
	ClearScreen();
	writeln('Fajlbol kerjuk az adatokat fajlba? (i/n):');
	readln(valaszt);
	if( valaszt = 'i') then
	begin
		Assign(tfOut, TESZT_FILE);
		rewrite(tfOut);
		Assign(tfIn, ADAT_FILE);
		reset(tfIn);
		while( true ) do
			begin
			readln(tfIn, szam);
			
			if( not (Ellenoriz(szam) ) ) then
			begin
				writeln(tfOut,szam);
				writeln(tfOut,'Rossz a megadas!');
				Close(tfIn);
				Close(tfOut);
				exit;
			end;
			Szetszed(szam, vSzam1);
			readln(tfIn, szam);
			if( not (Ellenoriz(szam) ) ) then
			begin
				writeln(tfOut,szam);
				writeln(tfOut,'Rossz a megadas!');
				Close(tfIn);
				Close(tfOut);
				exit;
			end;
			Szetszed(szam, vSzam2);
			
			if ( not (KozosSzamrendszer(vSzam1, vSzam2) ) ) then
			begin
				writeln(tfOut,'Nem kozos a szamrendszer, hiba!');
				Close(tfIn);
				Close(tfOut);
				exit;
			end;
			writeln(tfOut,'Elso    szam:',ValKiir(vSzam1));
			writeln(tfOut,'Masodik szam:',ValKiir(vSzam2));
			
			if ( VEgyenlo(vSzam1, vSzam2)) then
			begin
				writeln(tfOut, ValKiir(vSzam1),' = ',ValKiir(vSzam2));
			end
			else
			begin
				if ( VNagyobb(vSzam1, vSzam2) ) then
				begin
					writeln(tfOut, ValKiir(vSzam1),' > ',ValKiir(vSzam2));
				end
				else
				begin
					writeln(tfOut, ValKiir(vSzam1),' < ',ValKiir(vSzam2));
				end;
			end;
			
			writeln(tfOut,'Osszeguk   :',VOsszead(vSzam1,vSzam2));
			
			writeln(tfOut,'Kulonbseguk:',VKivon(vSzam1,vSzam2));
			
			writeln(tfOut,'Osztasuk:',VOszt(vSzam1,vSzam2));
			writeln(tfOut,'<<<--------------------------------------->>>');
		end;		
		Close(tfIn);
		Close(tfOut);
	end
	else
	begin
		ClearScreen();
		Ismerteto();
		while( true ) do
			begin
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
			Elvalaszto();
			writeln('Osztasuk:',VOszt(vSzam1,vSzam2));
		end;
	end;
END.

