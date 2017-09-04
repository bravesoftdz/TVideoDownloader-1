{ *
  * Copyright (C) 2014-2017 ozok <ozok26@gmail.com>
  *
  * This file is part of TVideoDownloader.
  *
  * TVideoDownloader is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 2 of the License, or
  * (at your option) any later version.
  *
  * TVideoDownloader is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with TVideoDownloader.  If not, see <http://www.gnu.org/licenses/>.
  *
  * }
unit UnitImageResize;

interface

uses Classes, Windows, SysUtils, Messages, StrUtils, Jpeg, Graphics, madGraphics;

type
  TImageResizer = class(TObject)
  private
    FSourcePath: string;
    FDestPath: string;

    function ResizeJpgEx(const inFile, outFile: string): Boolean;
  public

    constructor Create(const SourceImg: string; const DestImg: string);
    destructor Destroy; override;

    procedure Resize;
  end;

implementation

{ TImageResizer }

constructor TImageResizer.Create(const SourceImg, DestImg: string);
begin
  FSourcePath := SourceImg;
  FDestPath := DestImg;
end;

destructor TImageResizer.Destroy;
begin
  inherited;
end;

procedure TImageResizer.Resize;
var
  LExt: string;
begin
  if not FileExists(FSourcePath) then Exit;

  LExt := LowerCase(ExtractFileExt(FSourcePath));
  if (LExt = '.jpeg') or (LExt = '.jpg') then
  begin
    ResizeJpgEx(FSourcePath, FDestPath)
  end;
end;

function TImageResizer.ResizeJpgEx(const inFile, outFile: string): Boolean;
var
  LJpeg: TJPEGImage;
  LBMP: TBitmap;
  LJpegBMP: TBitmap;
  LOutJpeg: TJPEGImage;
begin
  Result := FileExists(inFile);

  LJpeg := TJPEGImage.Create;
  LBMP := TBitmap.Create;
  LJpegBMP := TBitmap.Create;
  try
    // try to load jpg from file
    try
      LJpeg.LoadFromFile(inFile);
    except
      Result := False;
      Exit;
    end;
    // output bitmap
    LBMP.PixelFormat := pf32bit;
    LBMP.Width := 180;
    LBMP.Height := Round(150 * (LJpeg.Height / LJpeg.Width));
    // bitmap to hold data from jpeg
    LJpegBMP.PixelFormat := pf32bit;
    LJpegBMP.Width := LJpeg.Width;
    LJpegBMP.Height :=LJpeg.Height;
    LJpegBMP.Assign(LJpeg);

    try
      StretchBitmap(LJpegBMP, LBMP, nil, nil, sqVeryHigh);
    except
      Result := False;
      Exit;
    end;

    LOutJpeg := TJPEGImage.Create;
    try
      LOutJpeg.Assign(LBMP);
      try
        LOutJpeg.SaveToFile(outFile);
      except
        Result := False;
        Exit;
      end;
    finally
      LOutJpeg.Free;
    end;
  finally
    LJpeg.Free;
    LBMP.Free;
    LJpegBMP.Free;
  end;
end;

end.

