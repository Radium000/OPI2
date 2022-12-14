program Project2;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Windows;

type
  TMatrix = array [1 .. 10, 1 .. 10] of integer;
  TShip = array [1 .. 10] of string;

procedure ClearConsoleWindow;
var
  cursor: COORD;
  r: cardinal;
begin
  r := 300;
  cursor.X := 0;
  cursor.Y := 0;
  FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', 80 * r,
    cursor, r);
  SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursor);
end;

procedure SetColor(AColor: integer);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), AColor and $0F);
end;

Function ConvertInputToCordinate(var Input: String): Boolean;
const
  SetOfLetters = 'АБВГДЕЖЗИК';
Var
  X, Y: integer;
  FoundX: Boolean;
  I, PosY, SignPos, CounterOfDigits: integer;
Begin
  FoundX := False;
  CounterOfDigits := 0;
  Input := AnsiUpperCase(Input);
  Result := True;

  For I := 1 To Length(Input) Do
  Begin
    SignPos := Pos(Input[I], SetOfLetters);

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
        if ('0' < Input[I]) or ((I - 1 > 0) and (Input[I - 1] + Input[I] = '10'))
        then
        begin
          Inc(CounterOfDigits);
          PosY := I;
        end;
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
    Input := Char(Y);
    if (X < 10) then
      Input := Input + Char(X)
    else
      Input := Input + Char(10);
  end
End;

function CheckCordsOnField(matrix: TMatrix; cords: string): Boolean;
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
  dx, dy: integer;
  flag: Boolean;
begin
  I := 1;
  while Pos(cords, ship_mas[I]) = 0 do
  begin
    I := I + 1;
  end;
  j := 3;
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
      for dx := -1 to 1 do
        for dy := -1 to 1 do
          if (ord(ship_mas[I][j - 2]) + dy >= 1) and
            (ord(ship_mas[I][j - 2]) + dy <= 10) and
            (ord(ship_mas[I][j - 1]) + dx >= 1) and
            (ord(ship_mas[I][j - 1]) + dx <= 10) and
            (matrix[ord(ship_mas[I][j - 2]) + dy, ord(ship_mas[I][j - 1]) +
            dx] = 0) then
            matrix[ord(ship_mas[I][j - 2]) + dy, ord(ship_mas[I][j - 1])
              + dx] := 2;
      j := j + 3;
    end;
    ship_mas[I] := '';
  end;

end;

procedure ChangeField(var matrix: TMatrix; var cords: string; ship_mas: TShip);
const
  SetOfSigns = 'АБВГДЕЖЗИК';
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
      if ansilowercase(s[j]) = 'м' then
        Result[I, j] := 0
      else if ansilowercase(s[j]) = 'к' then
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
      if correct then

      begin
        ShipLength := 1;
        if (field[I, j] < 0) and correct then
        begin
          field[I, j] := 1;
          if count < 11 then
            ships[count] := Char(I) + Char(j) + ' ';
          NewCords := Char(I) + Char(j);
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
                        NewCords := Char(y1 + dy) + Char(x1 + dx);

                      end;
                    end
                    else
                      correct := False;
                end;
            if NewCords <> '11' then
            begin
              Inc(ShipLength);
              if (ShipLength > 4) or (count > 10) then
                correct := False
              else
              begin
                ships[count] := ships[count] + NewCords[1] + NewCords[2] + ' ';
                field[ord(NewCords[1]), ord(NewCords[2])] := 1;
                y1 := ord(NewCords[1]);
                x1 := ord(NewCords[2]);
              end;
            end;

          until NewCords = '11';
          if ShipLength < 5 then
          begin
            shipsNum[ShipLength] := shipsNum[ShipLength] - 1;
            if shipsNum[ShipLength] < 0 then
              correct := False
            else
              Inc(count);
          end;

        end;
      end;
  if (shipsNum[1] <> 0) or (shipsNum[2] <> 0) or (shipsNum[3] <> 0) or
    (shipsNum[4] <> 0) then
    correct := False;
  Result := correct;
end;

procedure Render(field: TMatrix);
var
  I, j: integer;
begin

  writeln(' ');
  writeln('┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐');
  writeln('│   │ А │ Б │ В │ Г │ Д │ Е │ Ж │ З │ И │ К │');
  writeln('├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤');
  for I := 1 to 10 do
  begin
    write('│', I:2, ' ');
    for j := 1 to 10 do
    begin
      write('│');
      case field[I, j] of
        2:
          begin
            SetColor(2);
            write(' П ');
            SetColor(15);
          end;
        3:
          begin
            SetColor(14);
            write(' Р ');
            SetColor(15);
          end;
        4:
          begin
            SetColor(12);
            write(' У ');
            SetColor(15);
          end;
      else
        write('   ');

      end;
    end;
    writeln('│');
    if I <> 10 then
      writeln('├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤');
  end;
  writeln('└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘');

end;

procedure RenderAll(field1, field2: TMatrix);
var
  I, j: integer;
begin

  writeln('              Поле Первого игрока                                  Поле второго игрока            ');
  writeln('┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐        ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐');
  writeln('│   │ А │ Б │ В │ Г │ Д │ Е │ Ж │ З │ И │ К │        │   │ А │ Б │ В │ Г │ Д │ Е │ Ж │ З │ И │ К │');
  writeln('├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤        ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤');
  for I := 1 to 10 do
  begin
    write('│', I:2, ' ');
    for j := 1 to 10 do
    begin
      write('│');
      case field1[I, j] of
        2:
          begin
            SetColor(2);
            write(' П ');
            SetColor(15);
          end;
        3:
          begin
            SetColor(14);
            write(' Р ');
            SetColor(15);
          end;
        4:
          begin
            SetColor(12);
            write(' У ');
            SetColor(15);
          end;
        1:
          begin
            SetColor(9);
            write(' * ');
            SetColor(15);
          end;
      else
        write('   ');
      end;
    end;
    write('│        ');
    write('│', I:2, ' ');
    for j := 1 to 10 do
    begin
      write('│');
      case field2[I, j] of
        2:
          begin
            SetColor(2);
            write(' П ');
            SetColor(15);
          end;
        3:
          begin
            SetColor(14);
            write(' Р ');
            SetColor(15);
          end;
        4:
          begin
            SetColor(12);
            write(' У ');
            SetColor(15);
          end;
        1:
          begin
            SetColor(9);
            write(' * ');
            SetColor(15);
          end;
      else
        write('   ');
      end;

    end;
    writeln('│');
    if I <> 10 then
      writeln('├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤        ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤');
  end;
  writeln('└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘        └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘');
end;

procedure Game(var field: TMatrix; var ships: TShip; n: integer;
  var k: integer);
var
  p: integer;
  s: string;
  convert, check: Boolean;
begin
  ClearConsoleWindow;
  writeln('ХОД ', n, '-ГО ИГРОКА');
  Render(field);
  write(n, '-Й ИГРОК ВВЕДИТЕ КООРДИНАТЫ: ');
  ReadLn(s);
  repeat
    p := 6;
    convert := ConvertInputToCordinate(s);
    if convert then
    begin
      check := CheckCordsOnField(field, s);
      if check then
      begin
        ChangeField(field, s, ships);
        p := field[ord(s[1]), ord(s[2])];
        if ((p = 3) or (p = 4)) and (k < 20) then
          k := k + 1;
      end;
    end;
    ClearConsoleWindow;
    writeln('ХОД ', n, '-ГО ИГРОКА');
    Render(field);
    if convert then
      if check then
      begin
        case p of
          2:
            writeln('Промах');
          3:
            writeln('Ранил');
          4:
            writeln('Убил');
        end;
      end
      else
        writeln('Использованная клетка')
    else
      writeln('Неверные координаты');
    if (p > 2) and (k < 20) then
    begin
      write(n, '-Й ИГРОК ВВЕДИТЕ КООРДИНАТЫ: ');
      ReadLn(s);
    end;
    if (p = 2) and (k < 20) then
    begin
      writeln('Подтвердите ход следующего игрока');
      ReadLn;
    end;
  until (k = 20) or (p = 2);

end;

var
  matrix1, matrix2: TMatrix;
  k1, k2: integer;
  ships1, ships2: TShip;
  corr1, corr2: Boolean;

begin
  SetConsoleTitle(PChar('Морской бой'));
  writeln('                                 ██                ██ ');
  writeln(' █   █ ████ ████ ████ █  █ ████ █  █    ████ ████ █  █');
  writeln(' ██ ██ █  █ █  █ █  █ █ █  █  █ █  █    █    █  █ █  █');
  writeln(' █ █ █ █  █ ████ █    ██   █  █ █ ██    ████ █  █ █ ██');
  writeln(' █   █ █  █ █    █  █ █ █  █  █ ██ █    █  █ █  █ ██ █');
  writeln(' █   █ ████ █    ████ █  █ ████ █  █    ████ ████ █  █');
  writeln('                                            ');
  writeln('                          ▄▄                 ');
  writeln('                         ████                ');
  writeln('                         ████                ');
  writeln('                ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄       ');
  writeln('                ██                  ██       ');
  writeln('                ██▄▄  ▄▄  ▄▄  ▄▄  ▄▄██       ');
  writeln('                  ▀█  ██  ██  ██  █▀         ');
  writeln('                   █              █          ');
  writeln('                   ▀ ▄▄▄██  ██▄▄▄ ▀          ');
  writeln('               ▄▄▄████████  ████████▄▄▄      ');
  writeln('              ████████████  ████▀███████     ');
  writeln('               ███████████  ███▄ ▄█████      ');
  writeln('                ██████████  ██▀█ █▀███       ');
  writeln('                 █████████  ███▄▄▄███        ');
  writeln('                  ████████  ████████         ');
  writeln('                  ▀   ▀██▀  ▀██▀   ▀         ');
  writeln('▄███▄▄▄███▄▄▄███▄▄▄███▄▄▄▄██▄▄▄▄███▄▄▄███▄▄▄███▄▄▄███▄');
  writeln('▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀');

  writeln('Нажмите Enter чтобы играть');
  ReadLn;
  matrix1 := readMatrixFromFile('field1.txt');
  matrix2 := readMatrixFromFile('field2.txt');
  corr1 := isCorrect(matrix1, ships1);
  corr2 := isCorrect(matrix2, ships2);
  if corr1 then
    if corr2 then
    begin
      k1 := 0;
      k2 := 0;
      repeat
        Game(matrix2, ships2, 1, k1);
        if k1 <> 20 then
          Game(matrix1, ships1, 2, k2);
      until (k1 = 20) or (k2 = 20);
      ClearConsoleWindow;
      RenderAll(matrix1, matrix2);
      if k1 = 20 then
      begin
        writeln('Победил первый игрок!');
      end
      else
        writeln('Победил второй игрок!')
    end;
  if not corr1 then
    if not corr2 then
      writeln('Оба игровых поля заполнены неправильно!')
    else
      writeln('Игровое поле первого игрока заполнено неправильно!')
  else if not corr2 then
    writeln('Игровое поле второго игрока заполнено неправильно!');
  writeln('Нажмите Enter для завершения программы');
  ReadLn;

end.
