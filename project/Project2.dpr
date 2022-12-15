program Project2;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type
  TMatrix = array [1 .. 10, 1 .. 10] of integer;
  TShip = array [1 .. 10] of string;

Function ConvertInputToCordinate(var Input: String): Boolean;
Var
  SetOfSigns: String;
  X, Y: integer;
  FoundX: Boolean;
  I, PosY, SignPos, CounterOfDigits: integer;
Begin
  SetOfSigns := '����������';
  FoundX := False;
  CounterOfDigits := 0;
  Input := AnsiUpperCase(Input);
  Result := True;

  For I := 1 To Length(Input) Do
  Begin
    SignPos := Pos(Input[I], SetOfSigns);

    If SignPos > 0 Then
    Begin
      If Not FoundX Then
      Begin
        FoundX := True;
        X := ord(Input[I]) - 1039;;
      End
      Else
      Begin
        If X <> ord(Input[I]) - 1039 Then
          Result := False;
      End;
    End
    Else
    Begin
      If ('0' <= Input[I]) And (Input[I] <= '9') Then
      Begin
        Inc(CounterOfDigits);
        PosY := I;
      End;
    End;
  End;

  If FoundX Then
  Begin
    If (CounterOfDigits > 2) Or (CounterOfDigits < 1) Then
      Result := False
    Else
    Begin
      If CounterOfDigits = 1 Then
        Y := ord(Input[PosY]) - 48
      Else If (PosY = 1) or (Input[PosY] <> '0') or
        (Input[PosY - 1] <> '1') Then
        Result := False
      Else
        Y := 10;
    End;
  End
  Else
    Result := False;
  if Result then
  begin
    Input[1] := Char(Y);
    if (X < 10) then
      Input[2] := Char(X)
    else
      Input[2] := Char(10);
  end
End;

function CheckCordsOnField(matrix: TMatrix; cords: string): Boolean;
const
  SetOfSigns = '����������';
var
  pos1, pos2: integer;
begin
  pos1 := ord(cords[1]);
  pos2 := ord(cords[2]);
  if matrix[pos1, pos2] > 1 then
  begin
    Result := False;
  end
  else
  begin
    Result := True;
  end;
end;

procedure IfKilled(var matrix: TMatrix; var ship_mas: TShip; cords: string);
var
  I, j: integer;
  flag: Boolean;
begin
  I := 1;
  while Pos(copy(cords, 1 ,2), ship_mas[I]) = 0 do
  begin
    I := I + 1;
  end;
  j := Pos(' ', ship_mas[I]);
  flag := True;
  while (j <= Length(ship_mas[I])) and flag do
  begin
    if matrix[ord(ship_mas[I][j - 2]), ord(ship_mas[I][j - 1])] <> 3 then
    begin
      flag := False
    end;
    j := j + 3
  end;
  if flag then
  begin
    j := Pos(' ', ship_mas[I]);
    while (j <= Length(ship_mas[I])) do
    begin
      matrix[ord(ship_mas[I][j - 2]), ord(ship_mas[I][j - 1])] := 4;
      j := j + 3
    end;
    ship_mas[I] := '';
  end;

end;

procedure ChangeField(var matrix: TMatrix; var cords: string; ship_mas: TShip);
const
  SetOfSigns = '����������';
var
  pos1, pos2: integer;
begin
  pos1 := ord(cords[1]);
  pos2 := ord(cords[2]);
  if matrix[pos1, pos2] = 0 then
  begin
    matrix[pos1, pos2] := 2;
  end
  else if matrix[pos1, pos2] = 1 then
  begin
    matrix[pos1, pos2] := 3;
    IfKilled(matrix, ship_mas, cords);
  end;

end;

function readMatrixFromFile(const fileName: string): TMatrix;
var
  f: TextFile;
  s: string;
  I, j: integer;

begin
  for I := 1 to 10 do
    for j := 1 to 10 do
      Result[I, j] := 0;

  AssignFile(f, fileName);
  Reset(f);
  I := 1;
  while (not Eof(f)) and (I <= 10) do
  begin
    ReadLn(f, s);
    j := 1;
    while (j <= Length(s)) and (j <= 10) do
    begin
      if ansilowercase(s[j]) = '�' then
        Result[I, j] := 0
      else if ansilowercase(s[j]) = '�' then
        Result[I, j] := -1
      else
      begin
        delete(s, j, 1);
        dec(j);
      end;
      Inc(j);
    end;

    Inc(I);
  end;
  CloseFile(f);
end;

function isCorrect(var field: TMatrix; var ships: TShip): Boolean;
var
  shipsNum: array [1 .. 4] of integer;
  I, j, count, dx, dy, x1, y1, ShipLength: integer;
  NewCords: string;
  correct: Boolean;
begin
  shipsNum[1] := 4;
  shipsNum[2] := 3;
  shipsNum[3] := 2;
  shipsNum[4] := 1;
  count := 1;
  correct := True;

  for I := 1 to 10 do
    for j := 1 to 10 do
    begin
      ShipLength := 1;
      if field[I, j] < 0 then
      begin
        field[I, j] := 1;
        ships[count] := char(I) + char(j) + ' ';
        NewCords := char(I) + char(j);
        y1 := I;
        x1 := j;
        repeat
          NewCords := '11';
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
                      NewCords := char(y1 + dy) + char(x1 + dx);
                      y1 := y1 + dy;
                      x1 := x1 + dx;
                    end;
                  end
                  else
                    correct := False;
              end;
          if NewCords <> '11' then
          begin
            Inc(ShipLength);
            if ShipLength > 4 then
              correct := False
            else
            begin
              ships[count] := ships[count] + char(y1) + char(x1) + ' ';
              field[y1, x1] := 1;
            end;
          end;

        until NewCords = '11';
        shipsNum[ShipLength] := shipsNum[ShipLength] - 1;
        if shipsNum[ShipLength] < 0 then
          correct := False
        else
          Inc(count);

      end;
    end;
  if (shipsNum[1] <> 0) or (shipsNum[2] <> 0) or (shipsNum[3] <> 0) or
    (shipsNum[4] <> 0) then
    correct := False;
  Result := correct;
end;

procedure Render(field:TMatrix);
var i, j:integer;
begin
  for I := 1 to 10 do
  begin
    for j := 1 to 10 do
    begin
      case field[I, j] of
        2:
          write('�');
        3:
          write('�');
        4:
          write('�');
      else
        write(' ');

      end;
      write(' ');

    end;
    writeln;
  end;
end;
procedure Game(var field: TMatrix; var ships: TShip; n: integer;
  var k: integer);
var
  I, j, p: integer;
  s: string;
begin
  render(field);
  writeln('����������: ', n, '������' );
  ReadLn(s);
  repeat
    if ConvertInputToCordinate(s) then
    begin
      if CheckCordsOnField(field, s) then
      begin
        ChangeField(field, s, ships);
        render(field);
        p := field[ord(s[1]), ord(s[2])];
        case p of
          2:
            writeln('������');
          3:
            writeln('�����');
          4:
            writeln('����');
        end;
      end
      else
      begin
        render(field);
        writeln('�������������� ������');
      end;
    end
    else
      begin
        render(field);
        writeln('�������� ����������');
      end;

    if (p = 3) or (p = 4) then
    begin
      writeln('����������: ', n, '������' );
      ReadLn(s);

    end;
  until (n = 20) or (p = 2);

end;

var
  matrix1, matrix2: TMatrix;
  I, j, k1, k2: integer;
  ships1, ships2: TShip;

begin
  matrix1 := readMatrixFromFile('field1.txt');
  matrix2 := readMatrixFromFile('field2.txt');

  if isCorrect(matrix1, ships1) then
    if isCorrect(matrix2, ships2) then
    begin
      repeat
        Game(matrix1, ships1, 2, k2);
        if k2 <> 20 then
          Game(matrix2, ships2, 1, k1);
      until (k1 = 20) or (k2 = 20);
      if k1 = 20 then
        writeln('������� ������ �����!')
      else
        writeln('������� ������ �����!')
    end
    else
      writeln('������� 2 �����������')
  else
    writeln('������� 1 �����������');

  ReadLn;

end.
