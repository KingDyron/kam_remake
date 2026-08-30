unit KM_HouseSiegeWorkshop;
{$I KaM_Remake.inc}
interface
uses
  KM_CommonClasses, KM_Points, KM_Defaults,
  KM_Houses,
  KM_ResTypes;

type

  TKMHouseSiegeWorkshop = class(TKMHouseWFlagPoint)
  private
    fStoredMachines : array[1..2] of Word;
    procedure ConstructSiege(aUnitType : TKMunitType);
    function GetSiegeMachineIndex(aUnitType : TKMunitType) : Integer;
    function GetStoredMachines(aIndex : Integer) : Word;
  protected

  public
    constructor Create(aUID: Integer; aHouseType: TKMHouseType; PosX, PosY: Integer; aOwner: TKMHandID; aBuildState: TKMHouseBuildState);
    constructor Load(LoadStream: TKMemoryStream); override;
    procedure Save(SaveStream: TKMemoryStream); override;

    function HasOrders : Boolean;
    procedure FinishOrder(aOrderID : Byte);
    function PickOrder : Byte; override;
    function SiegeEquip(aUnitType : TKMunitType; aAmount : Integer): Integer;

    property StoredMachines[aIndex : Integer] : Word read GetStoredMachines;

    function ObjToString(const aSeparator: string = '|'): string; override;
  end;


implementation
uses
  SysUtils, TypInfo,
  KM_ScriptingEvents,
  KM_HandsCollection,
  KM_UnitWarrior;


{ TKMHouseWoodcutters }
constructor TKMHouseSiegeWorkshop.Create(aUID: Integer; aHouseType: TKMHouseType; PosX, PosY: Integer; aOwner: TKMHandID; aBuildState: TKMHouseBuildState);
begin
  inherited;

  fStoredMachines[1] := 0;
  fStoredMachines[2] := 0;
end;


constructor TKMHouseSiegeWorkshop.Load(LoadStream: TKMemoryStream);
begin
  inherited;
end;

procedure TKMHouseSiegeWorkshop.Save(SaveStream: TKMemoryStream);
begin
  inherited;
end;

function TKMHouseSiegeWorkshop.ObjToString(const aSeparator: string = '|'): string;
begin
  Result := inherited ObjToString(aSeparator);
end;

function TKMHouseSiegeWorkshop.HasOrders: Boolean;
var I : Integer;
begin
  Result := false;
  for I := 1 to 4 do
    If WareOrder[I] > 0 then
      Exit(true);

end;

function TKMHouseSiegeWorkshop.GetSiegeMachineIndex(aUnitType: TKMUnitType): Integer;
begin
  Assert(aUnitType in [utCatapult, utBallista], 'Unknown machine');
  Result := -1;
  case aUnitType of
    utCatapult: Result := 1;
    utBallista: Result := 2;
  end;

end;

function TKMHouseSiegeWorkshop.GetStoredMachines(aIndex : Integer) : Word;
begin
  Assert(aIndex in [1..2]);
  Result := fStoredMachines[aIndex];
end;

procedure TKMHouseSiegeWorkshop.ConstructSiege(aUnitType: TKMUnitType);
begin
  Inc(fStoredMachines[GetSiegeMachineIndex(aUnitType)]);
end;

function TKMHouseSiegeWorkshop.SiegeEquip(aUnitType: TKMUnitType; aAmount : Integer): Integer;
var
  newWarrior: TKMUnitWarrior;
  I, index : Integer;
begin
  Result := 0;
  // Make new siege machine
  index := GetSiegeMachineIndex(aUnitType);
  for I := 1 to aAmount do
  If fStoredMachines[index] > 0 then
  begin
    newWarrior := TKMUnitWarrior(gHands[Owner].TrainUnit(aUnitType, Self));
    Assert(newWarrior <> nil, 'Somehow siege machine was not created');
    newWarrior.Visible := False; //Make him invisible as he is inside the barracks
    newWarrior.SetActionGoIn(uaWalk, gdGoOutside, Self);
    if Assigned(newWarrior.OnUnitTrained) then
      newWarrior.OnUnitTrained(newWarrior);
    Dec(fStoredMachines[index]);
    Inc(Result);
  end else
    Break;

end;


function TKMHouseSiegeWorkshop.PickOrder: Byte;
var
  I, resI: Integer;
begin
  Result := 0;

  if WARFARE_ORDER_SEQUENTIAL then
    for I := 0 to 3 do
    begin
      resI := ((fLastOrderProduced + I) mod 4) + 1;
      If WareOrder[resI] > 0 then
      begin
        Result := resI;
        Break;
      end;

    end;

  if Result <> 0 then
  begin
    WareOrder[Result] := WareOrder[Result] - 1;
    fLastOrderProduced := Result;
    fNeedIssueOrderCompletedMsg := True;
    fOrderCompletedMsgIssued := False;
  end
  else
    //Check all orders are actually finished
    if  (WareOrder[1] = 0) and (WareOrder[2] = 0)
    and (WareOrder[3] = 0) and (WareOrder[4] = 0) then
      if fNeedIssueOrderCompletedMsg then
      begin
        fNeedIssueOrderCompletedMsg := False;
        fOrderCompletedMsgIssued := True;
        ShowMsg(TX_MSG_ORDER_COMPLETED);
      end;
end;

procedure TKMHouseSiegeWorkshop.FinishOrder(aOrderID : Byte);
begin
  Assert(aOrderID <> 0, 'Wrong order index:' + IntToStr(aOrderID) );
  ConstructSiege(MACHINES_ORDER[aOrderID])
end;

end.
