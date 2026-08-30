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
    fStoredMachines : array of TKMUnitType;
    fStoredCount : Word;
    procedure ConstructSiege(aUnitType : TKMunitType);
  protected

  public
    constructor Create(aUID: Integer; aHouseType: TKMHouseType; PosX, PosY: Integer; aOwner: TKMHandID; aBuildState: TKMHouseBuildState);
    constructor Load(LoadStream: TKMemoryStream); override;
    procedure Save(SaveStream: TKMemoryStream); override;

    function HasOrders : Boolean;
    procedure FinishOrder(aOrderID : Byte);
    function PickOrder : Byte; override;

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


procedure TKMHouseSiegeWorkshop.ConstructSiege(aUnitType: TKMUnitType);
var
  newWarrior: TKMUnitWarrior;
begin
  // Make new siege machine
  newWarrior := TKMUnitWarrior(gHands[Owner].TrainUnit(aUnitType, Self));
  newWarrior.Visible := False; //Make him invisible as he is inside the barracks
  newWarrior.SetActionGoIn(uaWalk, gdGoOutside, Self);
  if Assigned(newWarrior.OnUnitTrained) then
    newWarrior.OnUnitTrained(newWarrior);
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
