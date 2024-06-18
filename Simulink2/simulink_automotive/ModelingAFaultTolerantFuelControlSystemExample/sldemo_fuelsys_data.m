function varargout = sldemo_fuelsys_data(model, action, varargin)
% SLDEMO_FUELSYS_DATA - Function to manage the data used by Simulink
% model sldemo_fuelsys.
%
%   SLDEMO_FUELSYS_DATA(MODEL, ACTION, ...)
%
%   MODEL  - Model name or handle
% 
%   ACTION - One of the following:
%
%            'initialize_data'
%            'switch_lookup_data'
%            'switch_data_type'
%            'top_level_logging'
%            'set_info_text'
%            'showdemo'
%            'get_table_data'
%
%   The following describes each action.
%
%   1) INITIALIZE_DATA - Initialize the model for a specific signal data
%      type and lookup table implementation.
%
%      SLDEMO_FUELSYS_DATA(MODEL, ACTION, BREAKPOINT_TYPE, DATA_TYPE)
%
%      BREAKPOINT_TYPE
%
%      'orig': use original table data for fuelsys, which is comprised
%              mostly of uneven spaced breakpoints
%      'pow2': convert original table data to have even spaced power of 2
%              breakpoints
%
%      DATA_TYPE
%
%      'fixed': Configure controller for fixed-point data types
%      'float': Configure controller for floating point types (single
%               precision)
%
%   2) SWITCH_LOOKUP_DATA - Switch lookup table breakpoints
%
%      SLDEMO_FUELSYS_DATA(MODEL, ACTION, BREAKPOINT_TYPE)
%
%      See BREAKPOINT_TYPE above.
%
%   3) SWITCH_DATA_TYPE - Switch the data type for controller
%
%      SLDEMO_FUELSYS_DATA(MODEL, ACTION, DATA_TYPE)
%
%      See DATA_TYPE above.
%
%   4) TOP_LEVEL_LOGGING-  turn on/off relevant signal logging
%
%      SLDEMO_FUELSYS_DATA(MODEL, ACTION, LOGGING_VALUE)
%
%      LOGGING_VALUE
%
%      'on':  Turn on signal logging for relevant top-level signals
%      'off': Turn off signal logging for relevant top-level signals
%
%   5) SET_INFO_TEXT - sets the "?" info text clickFcn
%
%      SLDEMO_FUELSYS_DATA(MODEL,ACTION,DEMO_NAME)
%
%      DEMO_NAME - Name of the demo (e.g., rtwdemo_fuelsys)
%
%   6) SHOWDEMO - show the specified demo
%
%      SLDEMO_FUELSYS_DATA(MODEL, ACTION, DEMO_NAME, PRODUCT_NAME)
%
%      DEMO_NAME    - See above
%      PRODUCT_NAME - Name of the product corresponding to DEMO_NAME.
%
%   7) GET_TABLE_DATA - return the original table data (unevenly spaced)
%
%      SLDEMO_FUELSYS_DATA(MODEL, ACTION)
%
% Example usage:
% >> open_system('sldemo_fuelsys')
% >> sldemo_fuelsys_data('sldemo_fuelsys','initialize_data','pow2','float')
% >> sldemo_fuelsys_data('sldemo_fuelsys','switch_lookup_data','pow2')
% >> sldemo_fuelsys_data('sldemo_fuelsys','switch_data_type','fixed')
% >> sldemo_fuelsys_data('sldemo_fuelsys','top_level_logging','on')
% >> sldemo_fuelsys_data('sldemo_fuelsys','set_info_text','sldemo_fuelsys')
% >> sldemo_fuelsys_data('sldemo_fuelsys','showdemo','rtwdemo_fuelsys','Simulink Coder')
% >> td = sldemo_fuelsys_data('sldemo_fuelsys','get_table_data')

%
% Copyright 1994-2015 The MathWorks, Inc.
  
  switch action
      case 'initialize_data'
          if nargin ~= 4
              error(message('simdemos:sldemo_fuelsys_data:invalidArgsFour', action))
          end
          breakpoint_type = varargin{1};
          data_type = varargin{2};          
          create_bus_object();
          configure_data(model, breakpoint_type);
          create_numeric_type_objects(data_type);
          set_info_text(model,get_param(model,'Name'));
      case 'switch_lookup_data'
          if nargin ~= 3
              error(message('simdemos:sldemo_fuelsys_data:invalidArgsThree', action))
          end
          breakpoint_type = varargin{1};
          configure_data(model, breakpoint_type);
      case 'switch_data_type'
          if nargin ~= 3
              error(message('simdemos:sldemo_fuelsys_data:invalidArgsThree', action))
          end
          data_type = varargin{1};
          create_numeric_type_objects(data_type);
          set_datatype_based_data(model, data_type);
      case 'top_level_logging'
          if nargin ~= 3
              error(message('simdemos:sldemo_fuelsys_data:invalidArgsThree', action))
          end
          value=varargin{1};
          top_level_logging(model,value);
      case 'set_info_text'
          if nargin ~= 3
              error(message('simdemos:sldemo_fuelsys_data:invalidArgsThree', action))
          end
          demo_name=varargin{1};
          set_info_text(model,demo_name);
      case 'showdemo'
          if nargin ~= 4
              error(message('simdemos:sldemo_fuelsys_data:invalidArgsFour', action))
          end
          demo_name=varargin{1};
          product_name=varargin{2};
          loc_showdemo(demo_name, product_name)
      case 'get_table_data'
          if nargin ~= 2
              error(message('simdemos:sldemo_fuelsys_data:invalidArgsTwo', action))
          end
          varargout{1} = get_table_data();
      otherwise
          error(message('simdemos:sldemo_fuelsys_data:nofunction', action))
  end
end

function configure_data(model, breakpoint_type)
% Initializes the model data

% Initialize the original data set.  Note that much of the table data
% has uneven spaced breakpoints.  Later in this function, we will optionally
% convert the table data to have even spaced power of 2 breakpoints.

td = get_table_data();

% Constants

hys = 25;
zero_thresh = 250;

% Table data

switch breakpoint_type
    case 'orig'
        % Use the original fuelsys (mostly uneven) data
        SpeedVect = td.SpeedVect;
        PressVect = td.PressVect;
        ThrotVect = td.ThrotVect;
        
        RampRateKiX = td.RampRateKiX;
        RampRateKiY = td.RampRateKiY;
        RampRateKiZ = td.RampRateKiZ;
        
        PumpCon  = td.PumpCon;
        PressEst = td.PressEst;
        SpeedEst = td.SpeedEst;
        ThrotEst = td.ThrotEst;        
                        
    case 'pow2'
        % Compute even spaced power of 2 breakpoints    
        SpeedVect   = 64 : 2^5 : 640;             % 32 rad/sec
        PressVect   = 2*2^-5 : 2^-5 : 1-(2*2^-5); % 0.03 bar
        ThrotVect   = 0:2^1:88;                   % 2 deg
        RampRateKiX = 128:2^7:640;                % 128 rad/sec
        RampRateKiY = 0:2^-2:1;                   % 0.25 bar
        
        % Remap tables based on even spaced power of 2 breakpoints
        PumpCon  = interp2(td.PressVect,td.SpeedVect,td.PumpCon, PressVect',SpeedVect);
        PressEst = interp2(td.ThrotVect,td.SpeedVect,td.PressEst,ThrotVect',SpeedVect);
        SpeedEst = interp2(td.PressVect,td.ThrotVect,td.SpeedEst,PressVect',ThrotVect);
        ThrotEst = interp2(td.PressVect,td.SpeedVect,td.ThrotEst,PressVect',SpeedVect);
        
        % Compute Ramp Rate Ki
        RampRateKiZ = (1:length(RampRateKiX))' * (1:length(RampRateKiY)) * td.Ki;       

    otherwise
        error(message('simdemos:sldemo_fuelsys_data:nobreakpoint_type', breakpoint_type))
end

% Min/max values
min_press = max(min(PressVect),0.05);
max_press = min(max(PressVect),1);
min_speed = max(min(SpeedVect),0);
max_speed = 628;
min_throt = max(min(ThrotVect),3);
max_throt = min(max(ThrotVect),90);
max_ego   = 1.2;
st_range  = double(0.0001);

% Fault switch values
throttle_sw = 1;
speed_sw = 1;
ego_sw = 1;
map_sw = 1;

% Engine speed
engine_speed = 300;

% Assign in the model workspace
hws = get_param(model, 'ModelWorkspace');
hws.clear

hws.assignin('PressEst',PressEst);
hws.assignin('PressVect',PressVect);
hws.assignin('PumpCon',PumpCon);
hws.assignin('SpeedEst',SpeedEst);
hws.assignin('SpeedVect',SpeedVect);
hws.assignin('ThrotEst',ThrotEst);
hws.assignin('ThrotVect',ThrotVect);
hws.assignin('RampRateKiX',RampRateKiX);
hws.assignin('RampRateKiY',RampRateKiY);
hws.assignin('RampRateKiZ',RampRateKiZ);
hws.assignin('hys',hys);
hws.assignin('max_ego',max_ego);
hws.assignin('min_press',min_press);
hws.assignin('max_press',max_press);
hws.assignin('min_speed',min_speed);
hws.assignin('max_speed',max_speed);
hws.assignin('min_throt',min_throt);
hws.assignin('max_throt',max_throt);
hws.assignin('st_range' ,st_range);
hws.assignin('zero_thresh',zero_thresh);
hws.assignin('throttle_sw', throttle_sw);
hws.assignin('speed_sw', speed_sw);
hws.assignin('ego_sw', ego_sw);
hws.assignin('map_sw', map_sw);
hws.assignin('engine_speed', engine_speed);

% Configure the lookup tables to match the data.  Note: This is done
% after workspace variables are set so the block icon can see the
% new values.

lookupTables = find_system(get_param(model,'Handle'),'BlockType','Lookup_n-D');

for blkIdx = 1 : length(lookupTables)
    blkH = lookupTables(blkIdx);
    if strcmp(breakpoint_type,'orig')
        % orig        
        set_param(blkH,'IndexSearchMethod','Linear search')
        set_param(blkH,'InterpMethod','Linear')
        set_param(blkH,'ExtrapMethod','None - Clip')
        set_param(blkH,'UseLastTableValue','on')
    else
        % pow2
        set_param(blkH,'IndexSearchMethod','Evenly spaced points')
        set_param(blkH,'InterpMethod','None - Flat')
    end
    set_param(blkH,'ProcessOutOfRangeInput','None')
end

end

function td = get_table_data()
% Return the original table data for fuelsys
%   td.SpeedVect
%   td.PressVect
%   td.ThrotVect
%   td.PressEst
%   td.SpeedEst
%   td.ThrotEst
%   td.PumpCon
%   td.Ki
%   td.RampRateKiX
%   td.RampRateKiY
%   td.RampRateKiZ

td.Ki = 0.012;
td.RampRateKiX = 100:100:600;
td.RampRateKiY = 0:0.2:1;
td.RampRateKiZ = (1:length(td.RampRateKiX))' * (1:length(td.RampRateKiY)) * td.Ki;

td.SpeedVect = [50,75,100,125,150,175,200,250,300,350,400,450,500,600,700,800,900,1000];
td.PressVect = [0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95];
td.ThrotVect = [0,3,6,9,12,15,18,21,24,27,30,35,46,57,68,79,90];

td.PressEst = [...
0.806253176323533,0.87757598601382,0.957740646602364,0.985153049483995,0.993888908359001,0.997089947885844,0.998445305205399,0.999091830797014,0.999430938454035,0.999622818995239,0.999738270814208,0.999845542107005,0.999937181505709,0.999967346454435,0.999979873928593,0.999985850596962,0.999988872471833;...
0.553142316928701,0.687048893636338,0.884928073705099,0.959498363205152,0.983356257320681,0.992081090207251,0.995771008698205,0.997530140187631,0.998452542678774,0.998974388477469,0.99928834538053,0.999580035742161,0.999829204284437,0.999911219910389,0.999945280453193,0.999961530125998,0.999969746130731;...
0.37151500208954,0.482612303368962,0.772510257347488,0.91782922063029,0.966202131946129,0.983928124711611,0.991420178702962,0.994990142355732,0.996861498829361,0.997920027607395,0.998556801019289,0.999148366829447,0.999653659903192,0.999819973435009,0.999889041260296,0.999921992055277,0.999938652267344;...
0.277667903102846,0.354224278507773,0.634596441906303,0.858155181125974,0.941196863973347,0.972020092047905,0.985064576930091,0.991280051853728,0.994537692220384,0.996380159664924,0.997488437655209,0.998517971150347,0.999397308920136,0.999686725882367,0.999806915357152,0.999864254875951,0.999893246159778;...
0.220198954206677,0.278413460665919,0.499509252438175,0.780915653069415,0.90725506963059,0.955734788592824,0.976359298715029,0.986196279487014,0.991353075497716,0.994269777477944,0.996024221776188,0.997653989166547,0.999045967737845,0.999504103593618,0.999694357753908,0.999785123212449,0.99983101483727;...
0.181288665766343,0.227999583948868,0.398952953853525,0.690639436957016,0.863705911066113,0.934478804869502,0.964951264217872,0.979525847256624,0.987172517967595,0.991498792106339,0.994101447273549,0.996519319760225,0.998584517171801,0.999264242683749,0.999546520327838,0.999681188248569,0.999749277343391;...
0.153200000488606,0.191995727776301,0.330914655151405,0.595646844312617,0.810666723282258,0.90775046318795,0.950492505538488,0.971050093756693,0.981855086965011,0.987972552524888,0.991653973147472,0.995074698970308,0.997996914902605,0.998958792355415,0.999358253074229,0.999548828343865,0.999645185116666;...
0.11543102087155,0.144034515174401,0.243979118856238,0.429790108547636,0.682438642375562,0.836880642957011,0.91118032843611,0.947813899384122,0.96722856464052,0.978257580098748,0.984905309066455,0.991088428442116,0.996374579118731,0.998115314543176,0.998838330528732,0.999183288382611,0.999357707498247;...
0.0913067476324093,0.113642314330893,0.190658230936961,0.32878428638692,0.545074467052933,0.74462409246358,0.856657795837454,0.91488350746312,0.946318097747896,0.964311517705744,0.975196237184309,0.985342971016168,0.994032962585561,0.996897338116608,0.998087432486324,0.998655313115969,0.998942465702029;...
0.074651918860657,0.0927600764089701,0.154689629202074,0.263508735453851,0.428509373032026,0.639187152983657,0.787142203938478,0.87114532382285,0.918076257202549,0.945327888127594,0.961925625193849,0.977463094595001,0.990813081836746,0.995221210749437,0.997053747988697,0.997928394076558,0.998370715394031;...
0.0625231108323717,0.0776005353603968,0.128882197432187,0.217821230748895,0.34926567049653,0.533026414797681,0.705799478369783,0.816462064121936,0.881751459546042,0.920583784269911,0.944507657720157,0.967061575702449,0.986544638100701,0.992996396514112,0.995680976286613,0.996962784812372,0.997611133655427;...
0.0533383634276856,0.0661461394956957,0.109538590799923,0.18412267971606,0.29255219843447,0.440754788055134,0.618550870186323,0.752132326009762,0.837127815711564,0.889546778841832,0.922421304962653,0.953755223844687,0.981048433857061,0.990126104885857,0.993908561852908,0.995715616100314,0.996629889941259;...
0.0461719046290558,0.057223327839534,0.0945575552493262,0.158314103258091,0.249955267698337,0.372825322079962,0.53225525753417,0.681013721820078,0.784760241136601,0.852005161999648,0.895275306545621,0.937186788001516,0.974139712119363,0.986508158488532,0.991672018103867,0.994141054504847,0.995390743685847;...
0.0357830207157614,0.0443099388567923,0.0730034651165902,0.121584753293742,0.190411497153518,0.280611299170444,0.394398141965505,0.534281588633688,0.663365830090947,0.758897279500008,0.825346008939808,0.893138430722029,0.955345741069894,0.976600929210005,0.985531654326322,0.989812926442846,0.991982548835214;...
0.0286869137234658,0.0355034233512583,0.0583848257268498,0.0969201999867393,0.15104654695125,0.221078862790289,0.307794324372102,0.412602365520382,0.536233487336572,0.649402710410808,0.736919712291059,0.833757084996449,0.928773563241251,0.962402265836581,0.976685081430694,0.98356210634634,0.987054369021;...
0.0235863306154347,0.0291800197474993,0.047925624770081,0.0793847279015545,0.123326119357344,0.179727354097858,0.248796241080163,0.331018364047279,0.42724438204184,0.537134400774559,0.637336655478509,0.760335336541618,0.893359883114823,0.943066221776258,0.964537074160009,0.97494574259801,0.980248325729017;...
0.0197778405659999,0.0244618918010893,0.0401408494783853,0.0663889743999435,0.1029118379984,0.149540216925307,0.206232624555673,0.273087421642731,0.350367228565058,0.438541144409806,0.536700025323507,0.677028641058495,0.848668530687683,0.917867668307508,0.948508914226248,0.96351282465758,0.971192248524143;...
0.0168486334481795,0.0208349512025066,0.0341670824865201,0.0564468168291609,0.0873631839769212,0.126685025043463,0.174257811754556,0.2300045810957,0.29393137777248,0.366138241709143,0.44683771975245,0.589975331747287,0.795175419924348,0.886319899213546,0.928087683613587,0.948829361164199,0.959515454169781];

td.PumpCon = [...
-0.0556348,0.0185328,0.0419484,0.052676,0.0583284,0.0614432,0.0631079428571428,0.0638664,0.0640206666666667,0.063752,0.0631757454545454,0.0623688,0.0613844,0.0602605714285714,0.0590252,0.0576992,0.0562985647058824,0.0548357333333333,0.0533205263157895;...
-0.00228280000000001,0.0465088,0.0614657333333333,0.067964,0.0710788,0.0725018666666667,0.0729582285714286,0.0728104,0.0722597777777778,0.0714272,0.0703895636363636,0.0691981333333333,0.0678884,0.0664857142857143,0.0650086666666667,0.0634712,0.0618839764705882,0.0602552888888889,0.0585916842105263;...
0.0256932,0.0617968,0.0725244,0.076908,0.078754,0.0793312,0.0791833714285714,0.0785824,0.0776793333333333,0.0765648,0.0752964727272727,0.0739128,0.0724404,0.0708982857142857,0.0693004,0.0676572,0.0659766823529412,0.0642650666666667,0.0625272631578948;...
0.0435188,0.0720096,0.0801996,0.0833144,0.08439912,0.0844688,0.0839584571428571,0.0830856,0.0819710666666667,0.08068736,0.0792806181818182,0.0777816,0.0762116,0.0745858285714286,0.07291544,0.0712088,0.0694723058823529,0.0677109333333333,0.0659286105263158;...
0.0562692,0.0796848,0.0861830666666667,0.088452,0.0890292,0.0887605333333333,0.0880085142857143,0.0869544,0.0856988888888889,0.0843024,0.0828033818181818,0.0812274666666667,0.0795924,0.0779108571428572,0.0761921333333333,0.0744432,0.0726693882352941,0.0708748444444444,0.0690628421052632;...
0.0661194857142857,0.0859099428571428,0.0911998285714286,0.0928645714285714,0.0930792571428571,0.0925689142857143,0.0916442693877551,0.0904606857142857,0.0891044761904762,0.0876274285714286,0.0860624987012987,0.0844316571428571,0.0827501142857143,0.0810287346938776,0.0792754857142857,0.0774963428571428,0.0756958756302521,0.0738776380952381,0.0720444360902256;...
0.0741572,0.0912288,0.0956124,0.096824,0.0967668,0.0960752,0.0950210857142857,0.0937404,0.0923086666666667,0.0907712,0.0891568363636364,0.0874848,0.0857684,0.0840171428571429,0.082238,0.0804362,0.0786157411764706,0.0767797333333334,0.0749306315789474;...
0.08697,0.1002352,0.10335,0.1039272,0.10348936,0.102544,0.101308628571429,0.099892,0.0983545333333333,0.09673248,0.0950489090909091,0.0933192,0.091554,0.0897609142857143,0.08794552,0.086112,0.0842635529411765,0.0824026666666667,0.0805313052631579;...
0.0972452,0.1079728,0.110241733333333,0.110396,0.1097044,0.108589866666667,0.107233657142857,0.1057264,0.104118444444444,0.10244,0.100710290909091,0.0989421333333333,0.0971444,0.0953234285714286,0.0934838666666667,0.0916292,0.0897620941176471,0.0878846222222222,0.0859984210526316;...
0.106070342857143,0.114985371428571,0.116650114285714,0.116502285714286,0.115629428571429,0.114394057142857,0.112951534693878,0.111379542857143,0.109721238095238,0.108002514285714,0.106239849350649,0.104444228571429,0.102623257142857,0.100782367346939,0.0989255428571428,0.0970557714285714,0.095175337815126,0.0932860190476191,0.0913892180451128;...
0.1139892,0.1215448,0.1227564,0.122382,0.1213732,0.1200472,0.118539942857143,0.1169194,0.115223333333333,0.1134744,0.111687018181818,0.1098708,0.1080324,0.106176571428571,0.1043068,0.1024257,0.100535270588235,0.0986370666666667,0.0967323157894737;...
0.121303866666667,0.127802133333333,0.128661288888889,0.128110666666667,0.126996133333333,0.125599644444444,0.124042038095238,0.122383733333333,0.120658296296296,0.118885866666667,0.117079260606061,0.115247022222222,0.113395066666667,0.111527619047619,0.109647777777778,0.107757866666667,0.105859662745098,0.103954548148148,0.102043614035088;...
0.1281956,0.133848,0.1344252,0.1337336,0.13253448,0.1310816,0.129483714285714,0.1277952,0.126046266666667,0.12425504,0.122433054545455,0.120588,0.1187252,0.116848457142857,0.11496056,0.1130636,0.111159176470588,0.109248533333333,0.107332652631579;...
0.1411332,0.1455168,0.145671066666667,0.144768,0.143442,0.141904533333333,0.140246228571429,0.1385124,0.136728222222222,0.1349088,0.133063745454545,0.131199466666667,0.1293204,0.127429714285714,0.125529733333333,0.1236222,0.121708447058824,0.119789511111111,0.117866210526316;...
0.153345771428571,0.156823085714286,0.156675257142857,0.155621142857143,0.154204514285714,0.152606628571429,0.150905167346939,0.149138971428571,0.147329619047619,0.145490057142857,0.143628524675325,0.141750514285714,0.139859828571429,0.137959183673469,0.136050571428571,0.134135485714286,0.132215068907563,0.13029020952381,0.128361609022556;...
0.1651052,0.1679028,0.1675284,0.166361,0.1648764,0.1632332,0.161499371428571,0.1597089,0.157880666666667,0.156026,0.154152109090909,0.1522638,0.1503644,0.148456285714286,0.1465412,0.14462045,0.142695035294118,0.140765733333333,0.138833157894737;...
0.176562533333333,0.178831466666667,0.178280844444444,0.177025333333333,0.175487866666667,0.173809422222222,0.172050419047619,0.170241066666667,0.168398148148148,0.166531733333333,0.16464823030303,0.162751911111111,0.160845733333333,0.15893180952381,0.157011688888889,0.155086533333333,0.153157231372549,0.151224474074074,0.149288807017544;...
0.1878084,0.1896544,0.1889628,0.1876368,0.18605704,0.1843504,0.182571257142857,0.1807468,0.178892133333333,0.17701632,0.175125127272727,0.1732224,0.1713108,0.169392228571429,0.16746808,0.1655394,0.163606988235294,0.161671466666667,0.159733326315789];

td.SpeedEst = [...
471.83783972137,279.608397864926,203.371570611254,161.8787486246,135.709492497923,117.708903405276,104.597552018818,94.6535908661957,86.8841327758477,80.675803186167,75.3235987408633,70.3050930321351,65.4742360253649,60.6944949690365,55.8207660907439,50.6743433305652,44.9951652285928,38.3189908260105,29.5056655562855;...
550.809400909612,330.673297375769,242.26852873504,193.747159084239,162.957551629386,141.67966946265,126.123496556834,114.289217878186,105.018799398318,97.594251566389,91.1737064723463,85.1299344960694,79.2906767636512,73.4929197266039,67.5611474923051,61.2765189158975,54.3172285532483,46.1040923733648,35.2055605085197;...
777.559313277022,480.417440799461,358.002161788932,289.574202279002,245.543311415534,214.776328040985,192.07791115253,174.677692204617,160.956490038028,149.902110578226,140.278597740397,131.153610171063,122.277816777847,113.409376602425,104.280991396472,94.5509326446781,83.705557690075,70.8031609873486,53.4779650563955;...
1080.92434990449,685.372101847464,519.092057462468,424.676170483973,363.145673048974,319.692053974297,287.341871164569,262.345119103772,242.492868057991,226.394217833907,212.292318881674,198.846293954267,185.702134732112,172.50933166724,158.871868276136,144.272448006427,127.917919488172,108.326912550372,81.7063907826435;...
1418.36795322013,916.851376256768,703.229854643696,580.603095221263,499.94000853881,442.510230703477,399.445507543738,365.951590600047,339.189939777259,317.364349597567,298.151914987626,279.764113706134,261.730873981831,243.579971324357,224.769448277835,204.580168678984,181.892574292956,154.583190885904,117.117077445911;...
1769.74687680127,1160.1314328424,898.238993515751,746.787807025315,646.508597012421,574.688979015547,520.541064714086,478.214112005196,444.232947434523,416.391492625875,391.791212050025,368.186625303754,344.988267957597,321.598079997715,297.322232877249,271.229857827795,241.855607834812,206.386960225754,157.382577578816;...
2125.37309263935,1407.76452438693,1097.70378090141,917.473659193288,797.577905876503,711.335064829116,646.047348388092,594.814395514416,553.529203851986,519.579183098854,489.49454799578,460.575760678401,432.114190611351,403.385950235642,373.544920238797,341.447078245359,305.277093749081,261.519584827818,200.762546022977;...
2480.2034506654,1655.75761978137,1298.09727179509,1089.42803425652,950.132739955284,849.607686503322,773.270213387776,713.185295506684,664.623708146887,624.572837364542,589.001539364419,554.764041929731,521.034310353426,486.96446049424,451.558173068746,413.460864517961,370.510575211873,318.492792975403,246.018953244231;...
2831.37796793179,1901.808662448,1497.35579284241,1260.73461790173,1102.36519097486,987.786615401458,900.564356309899,831.747723593636,775.997173795666,729.90798909099,688.899853355633,649.390617909572,610.439281589141,571.076594684699,530.15924252267,486.126496205261,436.476678595697,376.308590039311,292.282778568289;...
3177.1400695945,2144.49278527693,1694.19192779751,1430.18899233724,1253.13123223848,1124.77668494257,1026.87671228218,949.48631941833,886.668843064165,834.636155172288,788.271994751692,743.568579579048,699.472690135679,654.89669774683,608.553985624548,558.6829023211,502.450584118529,434.285750511691,338.940084704028;...
3516.32917143061,2382.86747403876,1887.7517634672,1596.98966759448,1401.66698241218,1259.84425958553,1151.49973350585,1065.7170365502,995.976431700551,938.115566892664,886.49600271497,836.695488732213,787.551488496573,737.861144349535,686.198444354019,630.606384904028,567.930157525194,491.94692760058,385.549752105839;...
4064.90417866681,2768.85858210137,2201.51253250506,1867.63164732177,1642.876281514,1479.34457659158,1354.15682962093,1254.83174348032,1173.91065702869,1106.62887811061,1046.50914042027,988.463841700913,931.154917867196,873.194668518848,812.933675618733,748.102083629944,675.029769562251,586.451209451461,462.283276549317;...
5187.5536582049,3559.93784568518,2845.39982905067,2423.68113893442,2138.9681302302,1931.19988523555,1771.6718372989,1644.71499808623,1540.95928336809,1454.41450439158,1376.90154244357,1301.9842835045,1227.9688874288,1153.09356010507,1075.25742272398,991.559278287165,897.290333473879,783.085471474455,622.871451077645;...
7058.81244092784,5120.07633362899,3415.67249759347,2916.59803777156,2579.08427916718,2332.35229944546,2142.56519552183,1991.24652454498,1867.34355333296,1763.78778377408,1670.90629293198,1581.08041514928,1492.30435551432,1402.48876367426,1309.13803889951,1208.7997743787,1095.85957808202,959.1242501394,767.312631502771;...
7905.2133289905,4857.30446816772,3902.68104081193,3337.74407341489,2955.27603074438,2675.36755312393,2459.81057943173,2287.73814721368,2146.66511779659,2028.60528678136,1922.6162034325,1820.07475630878,1718.71021507893,1616.15528054261,1509.57971328753,1395.06422817669,1266.22809794773,1110.33274165035,891.700213222441;...
7710.468019974,5340.4795211573,5138.02264342828,3678.54554042742,3259.7735758443,2953.0713310185,2716.69993582276,2527.86174301408,2372.91490838085,2243.13226748765,2126.54721983279,2013.72662779576,1902.18612791079,1789.33441248671,1672.07169888745,1546.1028629502,1404.43064942514,1233.07405756645,992.823684550011;...
8213.01117303187,5695.38659373278,5427.47378987479,3928.96042836635,3483.54542386244,3941.97900226679,2905.53071698226,2704.38593216298,2539.25393459452,2400.86384248306,2276.49792356335,2156.12907620045,2037.11629797167,1916.70408848399,1791.59516670388,1657.21912691696,1506.12731593929,1323.42949162775,1067.33348108226];

td.ThrotEst = [...
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6.38557183666741,8.36078549102468;...
0,0,0,0,0,0,0,1.68952064775892,2.58459293118996,0,0,0,0,0,5.72108728076961,6.3750168521786,7.20563563331884,8.39975976982351,10.6117509444352;...
0,0,0,0,0,1.76802310777461,2.92603728143597,3.68765265549568,4.2827107614983,0,0,0,6.14796400589012,6.65737848247362,7.23481380756777,7.92705115220155,8.82334793593341,10.1353075311753,12.6118337694851;...
0,0,0,0,2.23554727549034,3.45390489695181,4.29428243321988,4.96177408946325,5.52152437709265,6.00442951618664,6.45575287330264,6.91762377708157,7.40645853591457,7.94329727562219,8.55895105992222,9.30473054681604,10.2797398746146,11.7206270987892,14.4699904584988;...
0,0,0,2.00945116292016,3.56980410482401,4.57394930642981,5.35854644463211,6.01267023811018,6.57608118903583,7.07068982618833,7.53897649948701,8.02325885387935,8.54037682418046,9.11265211291579,9.77342385955991,10.5788305954593,11.6379994274808,13.2126634608191,16.2388908630509;...
0,0,0,3.26512675748984,4.54951864911428,5.50260885317693,6.28151203903057,6.9460898992458,7.52690613968154,8.04209592063777,8.53383677876633,9.04579246774152,9.59562216583646,10.2071832656666,10.9165151191999,11.7847066269243,12.9310015111071,14.6423143468311,17.9485618603934;...
0,0,3.26939890783266,4.93993697812215,6.12848554855993,7.08785924601728,7.9029323976024,8.61479491409082,9.2470988876756,9.81495020245894,10.3624457435875,10.9372309946699,11.559048172117,12.255137310414,13.0671803261239,14.0663919749844,15.3925393313355,17.3835353180801,21.2600727314813;...
0,1.97904504866644,4.68685315248027,6.25862088648567,7.47141627043916,8.48241463509671,9.35722587042053,10.1307970128162,10.8243913695934,11.4520950956594,12.0611893426105,12.7040053932019,13.4026283719018,14.1878941036806,15.1073406829871,16.2425902389803,17.7544477915884,20.0332049014743,24.4970795821847;...
0,3.49935436615977,5.83082912179049,7.42063295143371,8.6925289781201,9.77170752982322,10.7159817812692,11.5577750193981,12.3174528597223,13.008803044849,13.6828060700106,14.396806156051,15.1753752467028,16.0530950529225,17.0835569566403,18.3591169978511,20.0623044346245,22.637737086943,27.7107066047989;...
0,4.57612627196189,6.84534682782423,8.49318969125795,9.83954920575794,10.9951302867449,12.0141451285679,12.9279899720331,13.7567936325807,14.5143792471273,15.2557024704959,16.0433290287536,16.9044303761244,17.8774756101994,19.0223242159663,20.4424553066756,22.3429785904355,25.2253182760044,30.9341446513223;...
0,5.4899869374105,7.78334848286328,9.50824639884044,10.9374933516508,12.1744338663107,13.2716480112421,14.2602579413105,15.1605017586539,15.9864169636978,16.7971152572272,17.6605500704427,18.6065984454004,19.677765839258,20.9404225932695,22.5096284613761,24.6141026645188,27.8151016031611,34.1919954252064;...
1.88135273591948,6.31516301504729,8.67098690951994,10.4837670252906,12.0012600728996,13.3230077085424,14.5010295041136,15.5666018297716,16.5402737876564,17.4364027833076,18.3183955169832,19.2597456088894,20.2931446720398,21.4652976435462,22.8493616297414,24.5725086161537,26.8882811653654,30.4213918236144,37.504774338111;...
3.79849600229045,7.8143453304318,10.3498113351197,12.3572436949325,14.0618374770048,15.5608133318763,16.9067731149248,18.1320061284013,19.2580207189374,20.2999910166858,21.3302663163972,22.4338810423488,23.6495165775918,25.0328421524519,26.6715719766891,28.7190355532134,31.4829183963948,35.7285995578245,44.371432875346;...
5.11555629372529,9.19732422785629,11.9492443997711,14.1668720034946,16.0687142799863,17.7531415761398,19.2745192692445,20.6666509650554,21.9522461670901,23.1474215110058,24.3339174774984,25.6089808801288,27.0178479496848,28.6260675176708,30.5375409305631,32.9350270586942,36.1881555417967,41.2277477056535,51.6991471191527;...
6.24242295476299,10.5135378018799,13.5020175722867,15.9404757448486,18.0477414534266,19.9250387905807,21.6291037798254,23.1955175631949,24.6483184159076,26.0046309530839,27.3560645640754,28.8128629411026,30.4275204239407,32.2766345290121,34.4824245581978,37.2614676418117,41.0561700114902,46.9991894427332,59.7145600188598;...
7.27207202821189,11.7881627211469,15.0266793865412,17.6946205311027,20.0148343673189,22.0923611407587,23.9866631108049,25.7352575608424,27.3635907811683,28.8898376231783,30.4160196605077,32.0663185268805,33.9013810420667,36.0103736823143,38.5366722900452,41.7366991530738,46.1411752613639,53.1408741058761,68.8121019668407;...
8.24307752438666,13.0358730041026,16.5348533930163,19.4401179418127,21.9807248385761,24.2661341475978,26.3587689895536,28.2981951067231,30.1113294030184,31.8174363088206,33.5295893568537,35.3870586461495,37.4598056380896,39.8515879531095,42.7308211151926,46.402332172253,51.5085029877518,59.7919671468469,79.9040315711675];

end

function create_bus_object() 
% Initializes necessary bus object in the MATLAB base workspace 

% Bus object: EngSensors 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'throttle';
elems(1).Dimensions = 1;
elems(1).DataType = 's16En3';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Unit = 'deg';

elems(2) = Simulink.BusElement;
elems(2).Name = 'speed';
elems(2).Dimensions = 1;
elems(2).DataType = 's16En3';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Unit = 'rad/s';

elems(3) = Simulink.BusElement;
elems(3).Name = 'ego';
elems(3).Dimensions = 1;
elems(3).DataType = 's16En7';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Unit = 'V';

elems(4) = Simulink.BusElement;
elems(4).Name = 'map';
elems(4).Dimensions = 1;
elems(4).DataType = 'u8En7';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Unit = 'bar';

EngSensors = Simulink.Bus;
EngSensors.HeaderFile = '';
EngSensors.Description = sprintf('');
EngSensors.Elements = elems;
assignin('base', 'EngSensors', EngSensors)

end

function top_level_logging(model,value)
% Turn signal logging on/off for the relevant top-level signals

list = {'throttle','speed','ego','map','fuel','air_fuel_ratio'};
for idx = 1:length(list)
    port=find_system(model,'FindAll','on','SearchDepth',1,...
        'Name',list{idx},'Type','port');
    if ~isempty(port)
        set_param(port,'DataLogging',value);
    end
end
end

function create_numeric_type_objects(data_type)
% Initializes necessary numeric type objects in the MATLAB base workspace

switch data_type
    case 'float'
        fltdt = fixdt('single');
        u8En7   = fltdt;
        s16En3  = fltdt;
        s16En7  = fltdt;
        s16En15 = fltdt;
    case 'fixed'
        u8En7   = fixdt(0,8,7);
        s16En3  = fixdt(1,16,3);
        s16En7  = fixdt(1,16,7);
        s16En15 = fixdt(1,16,15);
    otherwise
        error(message('simdemos:sldemo_fuelsys_data:nodata_type', data_type))
end

assignin('base', 'u8En7',   u8En7);
assignin('base', 's16En3',  s16En3);
assignin('base', 's16En7',  s16En7);
assignin('base', 's16En15', s16En15);

end

function set_datatype_based_data(model, data_type)
% Sets lower and upper bound of CheckRange to 
% appropriate value dependent on data_type.
st_range = 0.0001;
switch data_type
    case 'float'
        st_range = double(st_range);
    case 'fixed'
        st_range = fi(st_range, 1, 16, 15);
    otherwise    
            error(message('simdemos:sldemo_fuelsys_data:nodata_type', data_type))
end

hws = get_param(model, 'ModelWorkspace');
hws.assignin('st_range',st_range);

end

function set_info_text(model,demo_name)
% Sets the model's ? clickFcn to point to the right codepad file
% model     - name of model
% demo_name - name of demo
ah = find_system(model, 'SearchDepth', '1', 'FindAll', 'on', ...
    'type','annotation', 'Tag', 'DemoInfo');

if ~isempty(ah)
    nl=sprintf('\n');
    actionTxt = ['showdemo(''',demo_name,''')'];
    probTxt = [...
        'errordlg(',...
        'getString(message(''simdemos:sldemo_fuelsys_data:demoHelpNotFound'', sld_ME.message)), sld_ME.identifier)'];
    clickTxt = [...
        'try',nl,...
        actionTxt,nl,...
        'catch sld_ME',nl,...
        probTxt,nl,...
        'clear sld_ME',nl,...
        'end',nl];
    set(ah,'ClickFcn',clickTxt);
end
end

function loc_showdemo(demo_name, product_name)
% Show the specified demo, and error if the product is not installed.
% demo_name - Name of demo
% product_name - Name of product (e.g., 'Simulink Coder')
try
    showdemo(demo_name)
catch %#ok
    errordlg(getString(message('simdemos:sldemo_fuelsys_data:productNotInstalled', product_name)), demo_name)
end
end

function compute_filter_initial_conditions() %#ok
% Computes the initial condition of the low mode and rich mode filters
% Note: this function is not called.  It's purpose is to document how to
% set the IC of the filter blocks to match the results of the original
% fuelsys model.

% ../FuelRateController/FuelCalculation/SwitchableCompensation/LOW Mode
N = [8.7696 -8.5104];
D = [1 -0.74082];
U0 = -0.01;
Y0 = -0.01;

[A,B,C,Dd]=tf2ss(N,D);

LowModeIC = getxo(A,B,C,Dd,U0,Y0,1); %#ok

% ../FuelRateController/FuelCalculation/SwitchableCompensation/RICH Mode
N = [0 0.25918];
D = [1 -0.74082];
U0 = 1.6;
Y0 = 1.6;

[A,B,C,Dd]=tf2ss(N,D);

RichModeIC = getxo(A,B,C,Dd,U0,Y0,1); %#ok

end