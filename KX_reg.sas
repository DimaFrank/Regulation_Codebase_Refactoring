
  data test1;
     set cfh.rts24_journal_20230413(obs=50)
     Acm1.Order_events_acm01_202304(obs=50 rename=(OrderId=Order_id OrderType=order_type Side=BuySell Price=Price_));
  run;



  proc ds2;

   package KX_reg / overwrite=yes;

     dcl varchar(50) Submittingentity NonExecutingBrocker Duration UTI;
     dcl char TradingCapacity;
     dcl varchar(4) ValidPeriod;
     dcl double Dea;
     dcl double TradedQuantity TransactionPrice Notional;
     dcl int Multiplyer;
     dcl private varchar(20) Platform;


     method KX_reg();
        put 'KX_reg Object has been created!';
     end;

     method kx_reg(double dea, char tradingcapacity);
           this.Dea=dea;
           this.TradingCapacity=tradingcapacity;
           put 'Kx_reg overloaded constructor has been worked!';
     end;


     method notional_calc(double quantity, double price) returns double;
        notional=quantity*price;
        return notional;
     end;

     method notional_calc(double quantity, double price, int mult) returns double;
         notional=quantity*price*mult;
         return notional;
     end;

     method UTI_builder();
        if this.platform in ('acm01', 'cosmos01') then do;
            uti=cat(this.Submittingentity,'_', this.NonExecutingBrocker);
        end;
        else do;
            uti=cat(this.Submittingentity,'_', this.NonExecutingBrocker,'_','XXXX');
        end;
     end;

     method getSubmittingentity() returns varchar(50);
          return this.Submittingentity;
     end;

     method setSubmittingentity(varchar(50) entity);
           this.Submittingentity=entity;
     end;

     method getNonExecutingBrocker() returns varchar(50);
          return this.NonExecutingBrocker;
     end;

     method setNonExecutingBrocker(varchar(50) broker);
           this.NonExecutingBrocker=broker;
     end;

     method getPlatform() returns varchar(20);
          return this.Platform;
     end;

     method setPlatform(varchar(20) platform);
           if platform='' then do;
             this.Platform='CFH';
           end;
           else do;
             this.Platform=platform;
           end;
     end;


     method capacity_calc(int duration) returns varchar(4);

        dcl varchar(20) result;
        if duration>0 and duration<3 then result='FOKV';
           else result = 'DAVY';

        return result;

     end;


   endpackage;
   run;

  quit;



  proc ds2;

     data rts24_report / overwrite=yes;


      dcl package KX_reg kx1(dea=1, tradingcapacity='DEAL');

      dcl varchar(50) Submittingentity AccountId NonExecutingBrocker UTI;
      dcl char TradingCapacity;
      dcl varchar(4) ValidPeriod;
      dcl double Dea;
      dcl double TradedQuantity TransactionPrice Notional;
      dcl int Multiplyer Duration;
      dcl varchar(20) platform;

      keep Submittingentity, NonExecutingBrocker, TradingCapacity, UTI, Dea, Platform stam;

      METHOD RUN();

         set test1;
         kx1.setSubmittingentity('549300FSY1BKNGVUOR59');
         kx1.setNonExecutingBrocker(AccountId);
         kx1.setPlatform(platform);
         kx1.UTI_builder();


         Submittingentity=kx1.getSubmittingentity();
         NonExecutingBrocker=kx1.getNonExecutingBrocker();
         UTI=kx1.uti;
         TradingCapacity=kx1.capacity_calc(duration);
         Dea=kx1.dea;
         platform=kx1.getPlatform();
      END;

      METHOD TERM();

         put 'End of the program';

      END;

     enddata;
     run;

  quit;
