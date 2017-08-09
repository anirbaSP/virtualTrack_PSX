function pix=LumToPix(lum)

sDef=screenDefs;
pix=exp(log(lum/sDef.a)/sDef.b);

end