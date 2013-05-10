with Ada.Text_IO;				use Ada.Text_IO;
with Ada.Command_Line;				use Ada.Command_Line;
with Ada.Numerics.Generic_Elementary_Functions;
use Ada.Numerics;

with Vector_Space;				use Vector_Space;
with Parameter_File;				use Parameter_File;

procedure Main is

   package Numerics is new Generic_Elementary_Functions( Value_Type );
   use Numerics;

   Outp                 : File_Type;
   CFG                  : Parameter_File.Object;

   CFG_WL               : constant Natural := Register(CFG, "WL");
   CFG_C                : constant Natural := Register(CFG, "C" );
   CFG_NX               : constant Natural := Register(CFG, "NX");
   CFG_NY               : constant Natural := Register(CFG, "NY");
   CFG_D                : constant Natural := Register(CFG, "D" );
   CFG_Probe_Y          : constant Natural := Register(CFG, "Probe_Y" );
   CFG_Probe_N          : constant Natural := Register(CFG, "Probe_N" );
   CFG_EA		: constant Natural := Register(CFG, "EA" );
   CFG_DT		: constant Natural := Register(CFG, "DT" );


   PI                   : constant Value_Type 		:= 3.14159265358979;

   -- wave propagation paramters
   WL                   : Value_Type  	:= 1.0;
   C                    : Value_Type  	:= 1.0;

   -- oscillator array parameters
   NX                   : Integer 	:= 0;
   NY                   : Integer 	:= 0;
   D                    : Value_Type    := 0.0;
   DP 			: Value_Type    := 0.0;

   -- parameters of the probe array
   Probe_Y              : Value_Type    := 0.0;
   Probe_N              : Integer	:= 160;
   Probe_Width          : Value_Type 	:= 0.0;

   ------------
   -- To_Rad --
   ------------
   function To_Rad(D : in Value_Type ) return Value_Type is
   begin
      return 2.0 * PI * D / 360.0;
   end To_Rad;

   ----------------
   -- To_Degrees --
   ----------------
   function To_Degrees(R : in Value_Type ) return Value_Type is
   begin
      return 360.0 * R / (2.0 * PI);
   end To_Degrees;

   -------
   -- F --
   -------
   function F( X : in Value_Type ) return Value_Type is
   begin
      return sin( 2.0*PI* X /WL) / X  ;
   end F;

   ---------------
   -- Intensity --
   ---------------
   function Intensity( X : in Vector_Type; T : in Value_Type ) return Value_Type is
      Result : Value_Type := 0.0;
      N      : constant Integer := NX/2;
   begin
      for i in -N..N loop
         declare
            PX  : constant Value_Type := D*Value_Type(I);
         begin
            for j in 1..NY loop
               declare
                  PY       : Value_Type  := -D*Value_Type(J);
                  Distance : Value_Type := sqrt( Norm( X - Vector(PX,PY,0.0 )));
               begin
                  Result := Result + F( Distance + C*T + Value_Type(i) * DP );
               end;
            end loop;
         end;
      end loop;

      return Result/Value_Type(NX*NY) ;
   end Intensity;

   M             	: Natural := 0;
   Max_Intensity 	: Value_Type := 0.0;
   DT            	: Value_Type := 0.0;
   T		 	: Value_Type := 0.0;
   NUmber_Of_Time_Steps : Integer := 0;	 -- number of time steps
   Step_T	 	: Integer := 0;	 -- Current time step
   Records       	: Integer := 0;	 -- number of written records
begin
   Load( CFG, Argument(1) );

   declare
      Config_File_Name  : constant String := Argument(1) & ".cfg";
      Data_File_Name    : constant String := Argument(1) & ".data";
      Picture_File_Name : constant String := Argument(1) & ".png";
      EA		: Value_Type := 0.0;
   begin
      Create(Outp,Out_File, Data_File_Name );

      -- oscillator grid
      NX := Integer'Value(Parameter(CFG, CFG_NX, "60"));
      D  := Value_Type'Value(Parameter(CFG, CFG_D, "4.0"));
      NY := Integer'Value(Parameter(CFG, CFG_NY, "6"));

      -- wave propagtion parameters
      C  := Value_Type'Value(Parameter(CFG, CFG_C, "1.0"));
      WL := Value_Type'Value(Parameter(CFG, CFG_WL, "0.5"))*D;

      -- probe gird
      Probe_Y := Value_Type'Value(Parameter(CFG, CFG_Probe_Y, "0.0")) * D;
      Probe_N := Integer'Value(Parameter(CFG, CFG_Probe_N, "160" ));

      EA := To_Rad(Value_Type'Value(Parameter(CFG, CFG_EA, "0.0")));
      DP := D * sin(EA);

      DT  := Value_Type'Value(Parameter(CFG, CFG_DT, "0.1"));

      -- get the phase shift
      if Argument_Count > 1 then
         EA := To_Rad(Value_Type'Value(Argument(2)));
         DP := D * sin(EA);
      end if;

      -- get the starting time step
      if Argument_Count > 2 then
         Step_T := Integer'Value(Argument(3));
      end if;

      T := DT * Value_Type(Step_T);

      -- get the number of steps to go
      Number_Of_Time_Steps := 0;
      if Argument_Count > 3 then
         Number_Of_Time_Steps := Integer'Value(Argument(4));
      end if;

      M := Probe_N / 2;
      Probe_width := WL/2.0;

      Put_Line(Outp, "X,Y,Intensity,Time");
      for k in 0..Number_Of_Time_Steps loop
         for i in -M..M loop
            for j in -M..M loop
               declare
                  U : Value_Type := 0.0;
                  X : Vector_Type := Vector(
                               Probe_Width/2.0 + Value_Type(I)*Probe_Width,
                               Probe_Width/2.0 + Value_Type(J)*Probe_Width + Probe_Y,
                               0.0);
               begin
                  U := Intensity(X, T)**2;

                  if U > Max_Intensity then
                     Max_Intensity := U;
                  end if;

                  Records := Records + 1;

                  Put_Line( Outp, Value_Type'Image(Component(X,1)) & ","
                           & Value_Type'Image(Component(X,2)) & ","
                           & Value_Type'Image(U) & ","
                           & Value_Type'Image(T));
               end;
            end loop;
         end loop;
         T := T + DT;

      end loop;


      Close(Outp);


      Put_Line("file = " & Data_File_Name);
      Put_Line("points = " & Integer'Image(Records));
      Put_Line("format = ascii");
      Put_Line("interleaving = field");
      Put_Line("majority = column");
      Put_Line("field = locations, Itensity");
      Put_Line("structure = 2-vector, scalar");
      Put_Line("type = float, float");

   end;

end Main;



