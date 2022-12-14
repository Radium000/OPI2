program Project2;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type
  TMatrix = array [1 .. 10, 1 .. 10] of integer;
  TMas = array [1 .. 10] of string;

function readMatrixFromFile(const fileName: string): TMatrix;
var
  f: TextFile;
  s: string;
  i, j: integer;

begin
  for i := 1 to 10 do
    for j := 1 to 10 do
      Result[i, j] := 0;

  AssignFile(f, fileName);
  Reset(f);
  i := 1;
  while (not Eof(f)) and (i <= 10) do
  begin
    ReadLn(f, s);
    j := 1;
    while (j <= Length(s)) and (j <= 10) do
    begin
      if ansilowercase(s[j]) = 'ì' then
        Result[i, j] := 0
      else if ansilowercase(s[j]) = 'ê' then
        Result[i, j] := -1
      else
      begin
        delete(s, j, 1);
        dec(j);
      end;
      Inc(j);
    end;

    Inc(i);
  end;
  CloseFile(f);
end;

function isCorrect(var field: TMatrix; var ships: TMas;
  var correct: boolean): boolean;
var
  shipsNum: array [1 .. 4] of integer;
  i, j, count, dx, dy, x1, y1, ShipLength: integer;
  NewCords, cords: string;
begin
  shipsNum[1] := 4;
  shipsNum[2] := 3;
  shipsNum[3] := 2;
  shipsNum[4] := 1;
  count := 1;
  correct := true;

  for i := 1 to 10 do
    for j := 1 to 10 do
    begin
    ShipLength := 1;
      if field[i, j] < 0 then
      begin
        field[i, j] := 1;
        ships[count] := inttostr(i) + inttostr(j) + ' ';
        NewCords := inttostr(i) + ' ' + inttostr(j);
        y1 := i;
        x1 := j;
        repeat
          cords := NewCords;
          NewCords := '-1 -1';
          for dy := -1 to 1 do
            for dx := -1 to 1 do
              if (y1 + dy < 11) and (y1 + dy > 0) and (x1 + dx < 11) and
                (x1 + dx > 0) and correct then
              begin
                if abs(field[y1 + dy, x1 + dx]) = 1 then
                  if (dx and dy) = 0 then
                  begin
                    if field[y1 + dy, x1 + dx] = -1 then
                    begin
                      NewCords := inttostr(y1 + dy) + ' ' + inttostr(x1 + dx);
                      y1 := y1 + dy;
                      x1 := x1 + dx;
                    end;
                  end
                  else
                    correct := false;
              end;
          if NewCords <> '-1 -1' then
          begin
            Inc(ShipLength);
            if ShipLength > 4 then
              correct := false
            else
            begin
              ships[count] := ships[count] + inttostr(y1) + inttostr(x1) + ' ';
              field[y1, x1] := 1;
            end;
          end;

        until NewCords = '-1 -1';
        shipsNum[ShipLength] := shipsNum[ShipLength] - 1;
        if shipsNum[ShipLength] < 0 then
          correct := false
        else
          Inc(count);

      end;
    end;
  if (shipsNum[1]<>0) or (shipsNum[2]<>0) or (shipsNum[3]<>0) or (shipsNum[4] <> 0) then
    correct := false;
  Result := correct;
end;

var
  matrix: TMatrix;
  i, j: integer;
  ships: TMas;
  correct: boolean;

begin
  matrix := readMatrixFromFile('field.txt');
  for i := 1 to 10 do
  begin
    for j := 1 to 10 do
      write(matrix[i, j]:2, ' ');
    writeln;
  end;

  if iscorrect(matrix, ships, correct) then
  writeln('+')
  else writeln('-');
  for i := 1 to 10 do
  begin
    for j := 1 to 10 do
      write(matrix[i, j]:2, ' ');
    writeln;
  end;
  for i := 1 to 10 do
  writeln(ships[i]);
  ReadLn;

end.
