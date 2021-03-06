{
* 
* FIXUNIT.pas
* Copyright 2016 Erik <Erik@erik-pc>
* 
* CHDGC8 Gúth Erik Zoltán
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
	Szamj            = Char;
	ElojelTipus      = (Poz,Neg);
	PontossagTipus   = 0..MAXPONTOSSAG;
	SzamrendszerTipus= 2..35;
	PozSzam          = Array[0..MAXPONTOSSAG] of Szamj;
	EgeszSzam        = Record
						 hossz       : PontossagTipus;
						 jegy        : string;
					   End;
	ValosSzam		 = Record
						 elojel      : ElojelTipus;
						 egesz, tort : EgeszSzam;
						 szamrendszer: SzamrendszerTipus;
					   End;

	procedure Elvalaszto();
	procedure Ismerteto();
	procedure Beker(const kiir: string; var szam : string);
	procedure Szetszed(const szam : string; var valos : ValosSzam);
	procedure DebugSzam(const valos: ValosSzam);
	procedure Osszehoz(var v1 : ValosSzam; var v2 : ValosSzam);
	procedure StrToValos(var mit : string; var vSzam : ValosSzam );
	function IntToStr (i : integer) : String;
	function ValKiir(const valos : ValosSzam):string;
	function Ellenoriz(const szam : string) : boolean;
	function Szamjegy(const i : integer): string;
	function ValSzamjegy(const s : string):integer;
	function VezetoNullakElt(const szam : string) : string;
	function Pozitiv(const vSzam : ValosSzam): boolean;
	function KozosSzamrendszer(const vSzam1:ValosSzam; const vSzam2:ValosSzam):boolean;
	function VOsszead(const vSzam1C:ValosSzam; const vSzam2C:ValosSzam):string;
	function VKivon(const vSzam1C:ValosSzam; const vSzam2C:ValosSzam):string;
	function VNagyobb(const miC : ValosSzam; const minelC : ValosSzam): boolean;
	function VNagyobbVagyEgyenlo(const miC : ValosSzam; const minelC : ValosSzam): boolean;
	function VEgyenlo(const miC : ValosSzam; const minelC : ValosSzam): boolean;
	function VOszt(const vSzam1C:ValosSzam; const vSzam2C:ValosSzam):string;


Implementation


{
* neve: IntToStr 
* parameter: i (integer)
* visszatérés: string
* egész számot string-é alakítja
* }
function IntToStr (i : integer) : String;
var 
	s : string;
begin
   Str(i,s);
   IntToStr:=s;
end;

{
* neve: DebugSzam 
* parameter: valos (valós szám)
* hibakereséshez kiírja a valós számot minden paraméterével
* }
procedure DebugSzam(const valos: ValosSzam);
begin
	writeln('Elojel: ',valos.elojel);
	write('Egesz: ', valos.egesz.jegy);
	writeln('Hossz: ', valos.egesz.hossz);
	write('Tort: ', valos.tort.jegy);
	writeln('Hossz: ', valos.tort.hossz);
	writeln('Szamr: ', valos.szamrendszer);
end;

{
* neve: Osszehoz 
* parameter: v1 (valós szám), v2 (valós szám)
* törtrészeket egyenlő karakterszámra hozza (kiegészítés 0-val)
* }
procedure Osszehoz(var v1 : ValosSzam; var v2 : ValosSzam);
var
	db     : integer;
	i      : integer;
begin
	// ha különböző hosszak a törtrészek 0-val kiegészíteni a kissebbet
	if ( v1.tort.hossz <> v2.tort.hossz ) then
	begin
		db := v1.tort.hossz - v2.tort.hossz;
		if( db > 0 ) then
		// v2 kell
		begin 
			for i := 1 to db do
			begin
				 v2.tort.jegy := v2.tort.jegy + '0';
			end; 
			v2.tort.hossz := v1.tort.hossz;
		end
		else
		// v1 kell
		begin 
			db := abs(db);
			for i := 1 to db do
			begin
				 v1.tort.jegy := v1.tort.jegy + '0';
			end; 
			v1.tort.hossz := v2.tort.hossz;
		end;
	end;
end;


{
* neve: Elvalaszto 
* parameter: nincs
* egy elválasztó sort ír ki
* }
procedure Elvalaszto();
begin
	writeln('----------------------------------------------------------------------');
end;

{
* neve: ValKiir 
* parameter: valos (valós szám)
* visszatérés: sztring
* visszadja a valós számot a (+/-)egész,tört(számrendszer) formában
* }
function ValKiir(const valos : ValosSzam):string;
var
		kiirni : string;
begin 
	kiirni := '';
	if( valos.elojel = Poz ) then
	begin
		kiirni := '(+)';
	end
	else
	begin 
		kiirni := '(-)';
	end;
	kiirni := kiirni + valos.egesz.jegy+','+valos.tort.jegy+'('+IntToStr(valos.szamrendszer)+')';
	ValKiir := kiirni;
end;

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
	// nincs megadva semmi
	if ( Length(szam) = 0 ) then
	begin
		Ellenoriz := false;
		exit;
	end;
	
	// nagyobb karakterszámot akar megadni
	if ( Length(szam) > 200 ) then
	begin
		Ellenoriz := false;
		exit;
	end;
	
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
		// writeln('szamrendszer = ',szamrSz);
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
	// writeln('Egesz: ',egesz);
	// writeln('Tort: ', tort);

	// Pontosság leellenőrzése
	if( (Length(egesz)+Length(tort)) > MAXPONTOSSAG ) then
	begin
		Ellenoriz := false;
		exit;
	end; 
	
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
	if( vSzam.elojel = Poz) then
	begin
		Pozitiv := true;
	end
	else
	begin
		Pozitiv := false;
	end;
end;

{
* neve: Szetszed 
* parameter: szam (sztring), valos ( valós szám)
* szétszedi a valós számot részeire (előjel, egész, tört, számrendszer)
* }
procedure Szetszed(const szam : string; var valos : ValosSzam);
var
	nyit, zar : integer;
	kezdo     : integer;
	vesszo    : integer;
	egesz     : string;
	tort      : string;
begin
	// Előjel beállítása
	if( (szam[1] = '+') or (szam[1] = '-') )then
	begin
		kezdo := 2;
		if( szam[1] = '+') then
		begin
			valos.elojel := Poz;
		end
		else
		begin
			valos.elojel := Neg;
		end;
	end
	else
	begin
		kezdo := 1;
		valos.elojel := Poz;
	end;
	
	// számrendszer beállítása 	
	nyit := Pos('(',szam);
	// van számrendszer megadás
	if ( not( nyit = 0 ) ) then
	begin
		zar := Pos(')',szam);
		valos.szamrendszer := StrToInt( Copy( szam, nyit+1,zar-nyit-1));
	end
	else
	begin
		valos.szamrendszer := 10;
	end;
	
	// egész és törtrész beállítása 
	vesszo := Pos(',',szam);
	// van törtrész
	if ( not (vesszo = 0)) then
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
	valos.egesz.jegy := VezetoNullakElt(egesz);
	valos.egesz.hossz := Length(valos.egesz.jegy);
	valos.tort.jegy  := tort;
	valos.tort.hossz := Length(tort);
end;

{
* neve: Ismerteto 
* parameter: nincs
* a programról kiírja az ismertetőt
* }
procedure Ismerteto();
begin
	writeln('Fixpontos szamokkal vegzett muveletek');
	writeln('A szamjegyek hossza max (egesz+tort): 200 darab.');
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
function VezetoNullakElt(const szam : string) : string;
var
	ujSzam : string;
	ujHossz : integer;
begin
	ujSzam := szam;
	ujHossz := Length(szam);
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

{
* neve: KozosSzamrendszer 
* paraméter: vSzam1 (valós szám), vSzam2 ( valós szám )
* visszatérés: boolean
* ha eltérőek a számrendszerek akkor false, egyébként true
* }
function KozosSzamrendszer(const vSzam1:ValosSzam; const vSzam2:ValosSzam):boolean;
begin
	if ( vSzam1.szamrendszer <> vSzam2.szamrendszer ) then
	begin
		KozosSzamrendszer := false;
	end
	else
	begin 
		KozosSzamrendszer := true;
	end;
end;

{
* neve: Vnagyobb 
* paraméter: miC (valós szám), minelC ( valós szám )
* visszatérés: boolean
* ha mi nagyobb minél akkor true, egyébként false
* }
function VNagyobb(const miC : ValosSzam; const minelC : ValosSzam): boolean;
var
	i       : integer;
	mi,minel: ValosSzam;
begin
	mi    := miC;
	minel := minelC;
	// törtrészek összehozása
	Osszehoz(mi,minel);
	// ha nem egyenlőek az előjelek
	if( mi.elojel <> minel.elojel ) then
	begin 
		// amelyik pozitív az a nagyobb
		if ( mi.elojel = Poz ) then
		begin
			VNagyobb := true;
		end
		else
		begin
			VNagyobb := false;
		end;
	end
	else
	// egyforma előjelek
	begin
		// ha pozitivak, amelyik hosszabb az a nagyobb
		if (mi.elojel = Poz) then
		begin 
			if( mi.egesz.hossz > minel.egesz.hossz ) then
			begin
				VNagyobb := true;
			end
			else if( minel.egesz.hossz > mi.egesz.hossz) then
			begin 
				VNagyobb := false;
			end
			else
			// egyformák az egész részek
			begin 
				i := 1;
				while ( (mi.egesz.jegy[i] = minel.egesz.jegy[i]) and (i <= mi.egesz.hossz)) do
				begin 
					inc(i);
				end; 
				// az egész rész nagyobb
				if (i <= mi.egesz.hossz) then
				begin
					if( mi.egesz.jegy[i] > minel.egesz.jegy[i]) then
						VNagyobb := true
					else
						VNagyobb := false;
				end
				else
				// az egész rész egyforma, a tört rész számít
				begin
					// a két törtrész összehasonlítása
					i := 1;
					while( (mi.tort.jegy[i] = minel.tort.jegy[i]) and( i <= mi.tort.hossz) )do
					begin
						inc(i);
					end;
					//tört rész nagyobb
					if(i <= mi.tort.hossz ) then
					begin
						if( mi.tort.jegy[i] > minel.tort.jegy[i] ) then
						begin
							VNagyobb := true;
							exit;
						end
						else
						begin
							VNagyobb := false;
							exit;
						end;
					end;
					VNagyobb := false;
				end;
			end;
		end
		else
		// ha negatívak
		begin
			if (mi.egesz.hossz < minel.egesz.hossz) then
			begin
				VNagyobb := true;
			end
			else if( mi.egesz.hossz > minel.egesz.hossz) then
			begin
				VNagyobb := false;
			end
			else
			// egyforma hosszak egészeket végignézni
			begin 
				i := 1;
				while( (mi.egesz.jegy[i] = minel.egesz.jegy[i]) and ( i <= mi.egesz.hossz) )do
				begin
					inc(i);
				end;
				if( i <= mi.egesz.hossz ) then
				begin

					if( mi.egesz.jegy[i] < minel.egesz.jegy[i]) then
					begin
						VNagyobb := true;
					end
					else
					begin 
						VNagyobb := false;
					end;
				end
				else
				// egyforma egész, törtrészt kell nézni
				begin 
					i := 1;
					while( (mi.tort.jegy[i] = minel.tort.jegy[i]) and( i <= mi.tort.hossz) )do
					begin
						inc(i);
					end;
					//tört rész nagyobb
					if(i <= mi.tort.hossz ) then
					begin
						if( mi.tort.jegy[i] < minel.tort.jegy[i] ) then
						begin
							VNagyobb := true;
							exit;
						end
						else
						begin
							VNagyobb := false;
							exit;
						end;
					end;
					VNagyobb := false;
				end;
			end;
		end;
	end;
end;

{
* neve: VKivon 
* paraméter: vSzam1 (valós szám), vSzam2 ( valós szám )
* visszatérés: string
* a különbségük string-ben
* }
function VKivon(const vSzam1C:ValosSzam; const vSzam2C:ValosSzam):string;
var
	eltolas : integer;
	at		: integer;
	ertek   : integer;
	egesz   : string;
	tort    : string;
	i       : integer;
	vSzam1  : ValosSzam;
	vSzam2  : ValosSzam;
	tmp     : ValosSzam;
	teljes  : string;
	mibol   : integer;
	mit     : integer;
	csere   : boolean;
begin
	csere  := false;
	vSzam1 := vSzam1C;
	vSzam2 := vSzam2C;
	if ( VEgyenlo(vSzam1, vSzam2)) then
	begin
		VKivon := '(+)0,0('+IntToStr(vSzam1.szamrendszer)+')';
		exit;
	end;
	
	// egyforma előjel
	// 4 féle eset lehet
	if( vSzam1.elojel = vSzam2.elojel)then
	begin
		// a nagyobból kell kivonni a kisebbet és majd az előjelek függvényében
		// eldönteni az eredmény előjelét
		vSzam1.elojel := Poz;
		vSzam2.elojel := Poz;
		Osszehoz(vSzam1, vSzam2);
		// ha esetleg a második a nagyobb csere
		if ( VNagyobb( vSzam2, vSzam1) )then
		begin
			tmp    := vSzam1;
			vSzam1 := vSzam2;
			vSzam2 := tmp;
			csere := true;
		end;
		teljes:= '';
		tort  := '';
		egesz := '';
		mibol := 0;
		mit   := 0;
		at    := 0;
		for i := vSzam1.tort.hossz downto 1 do
		begin
			mibol := ValSzamjegy(vSzam1.tort.jegy[i]);
			mit   := ValSzamjegy(vSzam2.tort.jegy[i])+at;
			if ( mit > mibol ) then
			begin
				mibol := mibol + vSzam1.szamrendszer;
				at := 1;
			end
			else
			begin
				at := 0;
			end;
			ertek := mibol - mit;
			tort := Szamjegy(ertek)+tort;
		end; 
		
		eltolas := vSzam1.egesz.hossz - vSzam2.egesz.hossz;
		for i := vSzam2.egesz.hossz downto 1 do
		begin
			mibol := ValSzamjegy(vSzam1.egesz.jegy[i+eltolas]);
			mit   := ValSzamjegy(vSzam2.egesz.jegy[i])+at;
			if ( mit > mibol ) then
			begin
				mibol := mibol + vSzam1.szamrendszer;
				at := 1;
			end
			else
			begin
				at := 0;
			end;
			ertek := mibol - mit;
			egesz := Szamjegy(ertek)+egesz;
		end;
		// átvitel miatt lehet még számolás
		i := eltolas;
		while( i >= 1 )do
		begin
			if( at = 0)then
				break;
			mibol := ValSzamjegy(vSzam1.egesz.jegy[i]);
			mit := at;
			if( mit > mibol ) then
			begin
				mibol := mibol + vSzam1.szamrendszer;
				at := 1;
			end
			else
			begin
				at := 0;
			end;
			ertek := mibol - mit;
			egesz := Szamjegy(ertek)+egesz;
			dec(i);
		end;
		// ha maradtak még számjegyek
		while( i >= 1 )do
		begin
			egesz := vSzam1.egesz.jegy[i] + egesz;
			dec(i);
		end;
		// vezető nulla eltávolítása
		while( (Length(egesz) >1) and (egesz[1] = '0')) do
		begin
			Delete(egesz,1,1);
		end;
		// kivonás vége szám = egesz,tort
		teljes := egesz + ','+tort+'('+IntToStr(vSzam1.szamrendszer)+')';
		// 4 féle eset
		if( vSzam1C.elojel = Poz ) then
		begin 
			if ( csere ) then
				teljes := '(-)'+teljes
			else
				teljes := '(+)'+teljes;
		end
		else
		// negativ
		begin 
			if ( csere ) then
				teljes := '(+)'+teljes
			else
				teljes := '(-)'+teljes;
		end;
		VKivon := teljes;
	end
	else
	// különböző előjel
	begin 
		if ( vSzam2.elojel = Neg ) then
		begin
			vSzam2.elojel := Poz;
			VKivon := VOsszead(vSzam1, vSzam2);
		end
		else
		begin
			vSzam1.elojel := Poz;
			teljes := VOsszead(vSzam1, vSzam2);
			Delete(teljes,1,3);
			teljes := '(-)'+ teljes;
			VKivon := teljes;
		end;
	end;
end;

{
* neve: VOsszead 
* paraméter: vSzam1 (valós szám), vSzam2 ( valós szám )
* visszatérés: string
* az összegük string-ben
* }
function VOsszead(const vSzam1C:ValosSzam; const vSzam2C:ValosSzam):string;
var
	eltolas : integer;
	at		: integer;
	ertek   : integer;
	egesz   : string;
	tort    : string;
	i       : integer;
	vSzam1  : ValosSzam;
	vSzam2  : ValosSzam;
	tmp     : ValosSzam;
	teljes  : string;
	csere   : boolean;
begin
	vSzam1 := vSzam1C;
	vSzam2 := vSzam2C;
	tort := '';
	// ha előjelük egyformák
	if ( vSzam1.elojel = vSzam2.elojel) then
	begin
		vSzam1.elojel := Poz;
		vSzam2.elojel := Poz;
		// először a törtrésztösszeadni
		if( vSzam2.tort.hossz > vSzam1.tort.hossz) then
		begin
			tmp    := vSzam1;
			vSzam1 := vSzam2;
			vSzam2 := tmp;
		end;
		// ha csak másolni kell a karaktereket
		if( (vSzam1.tort.hossz - vSzam2.tort.hossz) > 0 ) then
		begin
			for i := vSzam1.tort.hossz downto vSzam2.tort.hossz + 1 do
			begin
				tort := vSzam1.tort.jegy[i] + tort;
			end; 	
		end;
		at := 0;
		for i := vSzam2.tort.hossz downto 1 do
		begin
			ertek := ValSzamjegy(vSzam1.tort.jegy[i]) + ValSzamjegy(vSzam2.tort.jegy[i]) + at;
			// ha nem lesz atvitel;
			if ( ertek < vSzam1.szamrendszer) then
			begin
				tort := szamjegy(ertek)+tort;
				at := 0;
			end
			else
			// van átvitel
			begin 
				tort := szamjegy(ertek-vSzam1.szamrendszer) + tort;
				at := 1;
			end;
		end; 

		// egész rész összeadása
		egesz:= '';
		if( VNagyobb(vSzam2, vSzam1)) then
		//csere
		begin
			tmp    := vSzam1;
			vSzam1 := vSzam2;
			vSzam2 := tmp;
		end;
		eltolas := vSzam1.egesz.hossz - vSzam2.egesz.hossz;
		//at := 0;
		for i := vSzam2.egesz.hossz downto 1 do
		begin
			ertek := ValSzamjegy(vSzam1.egesz.jegy[i+eltolas]) + ValSzamjegy(vSzam2.egesz.jegy[i]) + at;
			// ha nem lesz atvitel;
			if ( ertek < vSzam1.szamrendszer) then
			begin
				egesz := szamjegy(ertek)+egesz;
				at := 0;
			end
			else
			// van átvitel
			begin 
				egesz := szamjegy(ertek-vSzam1.szamrendszer) + egesz;
				at := 1;
			end;
		end; 
		i := eltolas;
		while( i >= 1 )do
		begin
			ertek := ValSzamjegy(vSzam1.egesz.jegy[i])+at;
			// ha nem lesz atvitel;
			if ( ertek < vSzam1.szamrendszer) then
			begin
				egesz := szamjegy(ertek)+egesz;
				at := 0;
			end
			else
			// van átvitel
			begin 
				egesz := szamjegy(ertek-vSzam1.szamrendszer) + egesz;
				at := 1;
			end;
			dec(i);
			if (at = 0) then
				break;
		end;
		// ha maradtak még számjegyek 
		while( i >= 1 )do
		begin
			egesz := vSzam1.egesz.jegy[i] + egesz;
			dec(i);
		end;
		if( (i = 0) and ( at = 1)) then
		begin
			egesz := '1' + egesz;
		end;

		teljes := '';
		if( vSzam1C.elojel = Poz ) then
			teljes := '(+)'
		else
			teljes := '(-)';
		teljes := teljes + egesz + ','+ tort+'('+IntToStr(vSzam1.szamrendszer)+')';
		
		VOsszead := teljes;
	end
	else
	// ha nem egyformák az előjelek	
	begin
		csere := false;
		vSzam1.elojel := Poz;
		vSzam2.elojel := Poz;
		if ( VNagyobb(vSzam2, vSzam1 ))then
		begin
			csere := true;
			tmp   := vSzam1;
			vSzam1:= vSzam2;
			vSzam2:= tmp;
		end;
		teljes := VKivon(vSzam1,vSzam2);
		
		// előjel beállítása ha kell 
		if ( csere ) then
		begin
			if ( vSzam2C.elojel = Neg) then
			begin
				Delete(teljes,1,3);
				teljes := '(-)'+teljes;
			end;
		end
		else
		begin
			if ( vSzam1C.elojel = Neg ) then
			begin
				Delete(teljes,1,3);
				teljes := '(-)'+teljes;
			end;
		end;
		VOsszead := teljes;
	end;
end;

{
* neve: VEgyenlo 
* paraméter: miC (valós szám), minelC ( valós szám )
* visszatérés: boolean
* ha egyenlőek a számok akkor true, egyébként false
* }
function VEgyenlo(const miC : ValosSzam; const minelC : ValosSzam): boolean;
var
	mi,minel    : ValosSzam;
begin
	mi := miC;
	minel := minelC;
	// törtrészek beállítása
	Osszehoz(mi, minel);
	// az egyes részeket összehasonlítjuk
	if ( (mi.elojel = minel.elojel) and (mi.egesz.jegy = minel.egesz.jegy) and (mi.tort.jegy = minel.tort.jegy) ) then
	begin
		VEgyenlo := true;
	end
	else
	begin 
		VEgyenlo := false;
	end;
end;

{
* neve: VOszt
* paraméter: vSzam1C (valós szám), vSzam2C ( valós szám )
* visszatérés: string
* max 10 jegyű eredménnyel tér vissza tizes számrendszerben
* !!! Tovább fejlesztési lehetőség ------->
* !!! Számrendszerek közötti átváltás
* HA nulla az osztó akkor a ''Nullaval nem lehet osztani!'-l tér vissza
* }
function VOszt(const vSzam1C:ValosSzam; const vSzam2C:ValosSzam):string;
var
	vSzam1,vSzam2 : ValosSzam;
	ered :string;
	h    :integer;
	i    :integer;
	elso : boolean;
	vmi  : ValosSzam;
	tmp  : string;
	szamr: string;
begin
	// kezdeti beállítások
	vSzam1 := vSzam1C;
	vSzam2 := vSzam2C;
	vSzam1.elojel := Poz;
	vSzam2.elojel := Poz;
	szamr  := IntToStr(vSzam1.szamrendszer);
	// nullával való összehasonlítás
	tmp := '(+)0,0('+szamr+')';
	StrToValos(tmp,vmi);
	// ha nulla akkor kilépés nullával való osztás nem lehet
	if ( VEgyenlo(vmi, vSzam2))then
	begin
		VOszt := 'Nullaval nem lehet osztani!';
		exit;
	end;
	
	if ( VNagyobb(vSzam2,vSzam1)) then
	begin 
		h := 0;
		ered := '0,';
		elso := false;
		while ( VNagyobb(vSzam2,vSzam1) ) do
		begin
			tmp := '(+)0,0('+szamr+')';
			StrToValos(tmp,vmi);
			for i := 1 to vSzam1.szamrendszer do
			begin
				tmp  := VOsszead(vmi,vSzam1);
				StrToValos(tmp,vmi)
			end;
			vSzam1 := vmi;
			inc(h);
		end;
		dec(h);
		for i := 1 to h do
		begin
			ered := ered + '0';
		end;
	end
	else
	begin
		ered := '';
		elso := true;
	end;
	tmp := '(+)0,0('+szamr+')';
	StrToValos(tmp,vmi);
	while( not (VEgyenlo(vSzam1,vmi)) )do
	begin
		h := 0;
		while( VNagyobbVagyEgyenlo(vSzam1,vSzam2) )do
		begin
			inc(h);
			tmp := VKivon(vSzam1,vSzam2);
			StrToValos(tmp,vSzam1);
		end;
		if (elso) then
		begin
			ered := IntToStr(h)+',';
			elso := false;
		end
		else
		begin
			ered := ered + IntToStr(h);
		end;
		if (VEgyenlo(vSzam1,vmi)) then
		begin
			break;
		end;
		while( VNagyobb(vSzam2,vSzam1) )do
		begin
			tmp := '(+)0,0('+szamr+')';
			StrToValos(tmp,vmi);
			for i:= 1 to vSzam1.szamrendszer do
			begin
				tmp := VOsszead(vmi,vSzam1);
				StrToValos(tmp,vmi);
			end;
			vSzam1 := vmi;
			tmp := '(+)0,0('+szamr+')';
			StrToValos(tmp,vmi);
		end;
		if ( Length(ered) > 10 ) then
			break;
	end;
	if ( vSzam1C.elojel = vSzam2C.elojel) then
		ered := '(+)'+ered
	else
		ered := '(-)'+ered;
	ered := ered + '(10)';
	VOszt := ered;
end;

{
* neve: StrToValos 
* parameter: mit (string), vSzam (valós szám)
* a string-et valós számmá alakítja
* }
procedure StrToValos(var mit : string; var vSzam : ValosSzam );
var
	tmp         : string;
	hol         : integer;
	meddig      : integer;
begin
	tmp := Copy(mit,2,1);
	if( tmp = '+' )then
		vSzam.elojel := Poz
	else
		vSzam.elojel := Neg;
		
	hol := Pos(',',mit);
	tmp := Copy(mit,4,hol-4);
	vSzam.egesz.jegy  := tmp;
	vSzam.egesz.hossz := Length(tmp);
	Delete(mit,1,3);
	hol := Pos(',',mit);
	meddig := Pos('(',mit);
	tmp := Copy(mit,hol+1,meddig-hol-1);
	vSzam.tort.jegy := tmp;
	vSzam.tort.hossz := Length(tmp);
	hol := Pos('(',mit);
	meddig := Pos(')',mit);
	tmp := Copy(mit,hol+1,meddig-hol-1);
	vSzam.szamrendszer := StrToInt(tmp);
end;

{
* neve: VNagyobbVagyEgyenlo 
* parameter: miC (valós szám), minelC (valós szám)
* visszatérés: boolean
* Ha miC >= minelC akkor true, egyébként false
* }
function VNagyobbVagyEgyenlo(const miC : ValosSzam; const minelC : ValosSzam): boolean;
begin
	if( (VNagyobb(miC,minelC)) or (VEgyenlo(miC,minelC)) ) then
		VNagyobbVagyEgyenlo := true
	else
		VNagyobbVagyEgyenlo := false;
end;

end.
