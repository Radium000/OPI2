program Project2;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type
  TMas = array [1 .. 10, 1 .. 10] of integer;

function readMatrixFromFile(const fileName: string): TMas;
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
  while (not Eof(f)) and (i<=10) do
  begin
    ReadLn(f, s);
    j := 1;
    while (j <= Length(s)) and (j<=10) do
    begin
      if ansilowercase(s[j]) = '�' then
        Result[i, j] := 0
      else if ansilowercase(s[j]) = '�' then
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

var
  matrix: TMas;
  i, j: integer;

begin
  matrix := readMatrixFromFile('field.txt');
  for i := 1 to 10 do
  begin
    for j := 1 to 10 do
      write(matrix[i, j]:2, ' ');
    writeln;
  end;
  ReadLn;

end.
