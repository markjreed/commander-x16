 d � TOWERS OF HANOI IN BASIC ?n ND �  8: � NUMBER OF DISCS _x BG � 15: � BACKGROUND COLOR �� BK � 11: � CLOSEST THING TO BLACK WITH 0=TRANSPARENT �� PC � 70: � PEG COLOR �� FC �  5: � FROM-PEG BACKGROUND COLOR 	� TC �  2: � TO-PEG BACKGROUND COLOR #	� Ά 128: Ί 0, 0, 319, 239, BG 0	� ΍ BG, 0 ?	� � I�1 � 12 a	� :  Β 11�I,4:� �(18)��(32,33) i	� � I �	� BX � 60 : BY � 162 : Y0 � BY � 72 : Y1 � BY � 1 : Y2 � BY � 15 �	� � I�0 � 2 �	� :  CX � BX � I � 96 : X1 � CX � 33 : X2 � X1 � 66 3
� : Ή X1, Y1, X2, Y2, 0 : Ί X1 � 1, Y1 � 1, X2 � 1, Y2 � 1, PC {
: Ή CX � 2, Y0, CX � 1, BY � 1, 0 : Ί  CX � 1, Y0 � 1, CX, BY, PC �
� I �
΍ BK �
"� P(2, ND) : � DISKS ON EACH PEG �
,P(0, 0) � ND : � I � 1 � ND : P(0, I) � ND � I : � : � START SETUP 6� 1000 : � INITIALIZE SPRITES 8@� 900 :  � DISPLAY STATE uJ� N(8), F(8), T(8), V(8) : � VARS FOR RECURSIVE SOLUTION �TN(0) � ND �^� LOOP OVER MOVING DISCS TO THE NEXT PEG �h� E�0 � 1 � 0 �r: � P�0 � 1 �|:   F � P : T � F � 1: � 460 ��: � P �: � P�2 � 1 � �1 3�:   F � P : T � F � 1: � 460 =�: � P \�: � K$: � K$ �� "" � E � 1 d�� E j�� x�� L�0 � 2 ��Β 22, 8 � 12 � L: ΍ BK, 0 : � �(65 � L) ��� L ��� Q � 0 � 10000 : � Q ��Β 22, 8 � 12 � F : ΍ 1, FC : � �(65 � F) &�Β 22, 8 � 12 � T : ΍ 1, TC : � �(65 � T) OF(0) � F : T(0) � T : SP � 1 : � 550 U� x� RECURSIVE SOLUTION FOR HANOI �&� N(SP � 1) � 0 � � �0V(SP � 1) � 3 � F(SP � 1) � T(SP � 1) : � VIA PEG :N(SP) � N(SP � 1) � 1 : F(SP) � F(SP � 1) : T(SP) � V(SP � 1) .DSP � SP � 1 : � 550 : SP � SP � 1 jNF � F(SP � 1) : T � T(SP � 1) : � 700 : � MOVE ONE DISK �XN(SP) � N(SP � 1) � 1 : F(SP) � V(SP � 1) : T(SP) � T(SP � 1) �bSP � SP � 1 : � 550 : SP � SP � 1 �l� ��� MOVE ONE DISK FROM F TO T �H1 � P(F, 0) : � STARTING HEIGHT E�D � P(F, H1) : � WHICH DISK TO MOVE t�H2 � P(T, 0) : � TARGET HEIGHT BEFORE MOVE ��H2 � H2 � 1 : P(T, H2) � D : P(T, 0)�H2 : P(F, 0) � H1 � 1 : � MOVE DISK ��� NOW ANIMATE THE MOVE �X1 � BX � F � 96 � 32 � (D � 2) � 16 : � OLD X BX2 � BX � T � 96 � 32 � (D � 2) � 16 : � NEW X jY0 � BY � 1 � H1 � 8 : � STARTING Y �Y1 � BY � 1 � 16 � 8 : � Y USED FOR HORIZONTAL MOVE � Y2 � BY � 1 � H2 � 8 : � ENDING Y �*� Y � Y0 � Y1 �  �1 :  ν D, X1, Y : � Y : � LIFT *4� X � X1 � X2 � T�F :  ν D, X, Y : � X I>� T � 0 � Y2 � Y1 : � DROP �H: Y � Y1 � T � T : � Y�� Y2 � Y � Y2 : T � Y2 � Y1 �R: ν D, X2, Y : � Q �0 � 9 : � Q �\� �f� ��� I�0 � 2 ��: � P(I, 0) � 0 � 980 ��: � J � 1 � P(I, 0) �:   D � P(I, J) 1�:   X � BX � I � 96 � 32 � (D � 2) � 16 L�:   Y � BY � 1 � J � 8 i�:   ν D, X, Y : λ D, 3 s�: � J {�� I ��� ��� INITIALIZE SPRITE DATA ��A � $3000 ��Β 30 ��� I � 1 � 12 �: � J � 1 � 150 �:   � B 
:   � B � �1 � J � 150: � 1070 ($:   ΄ 1, A, B: A � A � 1 2.: � J :8: � BB� I XLμ 0, 1, $3000, 0 sVλ 0, 0, 0, 0, 2, 0, 0 �`μ 1, 1, $3080, 0 �jλ 1, 0, 0, 0, 2, 0, 0 �tμ 2, 1, $3100, 0 �~λ 2, 0, 0, 0, 3, 0, 0 ��μ 3, 1, $3200, 0 �λ 3, 0, 0, 0, 3, 0, 0 �μ 4, 1, $3300, 0 7�λ 4, 0, 0, 0, 3, 0, 0 M�μ 5, 1, $3400, 0 h�λ 5, 0, 0, 0, 3, 0, 0 ~�μ 6, 1, $3500, 0 ��λ 6, 0, 0, 0, 3, 0, 0 ��μ 7, 1, $3600, 0 ��λ 7, 0, 0, 0, 3, 0, 0 ��� �� 0,0,0,0,0,0,187,187,187,187,0,0,0,0,0,0,0,0,0,0,187,187,187,17,17,187 g � 187,187,0,0,0,0,0,0,0,187,187,17,17,17,17,17,17,187,187,0,0,0,0,0,11 �
� 177,17,17,17,17,17,17,17,17,27,176,0,0,0,0,11,177,17,17,17,17,17,17 �� 17,17,27,176,0,0,0,0,0,187,187,17,17,17,17,17,17,187,187,0,0,0,0,0,0 H� 0,187,187,187,17,17,187,187,187,0,0,0,0,0,0,0,0,0,0,187,187,187,187,0 �(� 0,0,0,0,0,0,0,0,0,11,187,187,187,187,187,187,176,0,0,0,0,0,0,11,187 �2� 187,178,34,34,34,34,43,187,187,176,0,0,0,11,187,178,34,34,34,34,34,34 )<� 34,34,43,187,176,0,0,187,34,34,34,34,34,34,34,34,34,34,34,34,187,0,0 sF� 187,34,34,34,34,34,34,34,34,34,34,34,34,187,0,0,11,187,178,34,34,34 �P� 34,34,34,34,34,43,187,176,0,0,0,11,187,187,178,34,34,34,34,43,187,187 
Z� 176,0,0,0,0,0,0,11,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,0 Vd� 0,0,0,0,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0,0,0,0,0 �n� 0,0,0,0,0,0,0,0,0,187,187,187,51,51,51,51,51,51,51,51,187,187,187,0,0 �x� 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,187,187,51,51,51,51,51,51,51,51,51,51 7�� 51,51,187,187,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,179,51,51,51,51,51,51 ��� 51,51,51,51,51,51,51,51,59,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,179,51 ��� 51,51,51,51,51,51,51,51,51,51,51,51,51,59,176,0,0,0,0,0,0,0,0,0,0,0,0 �� 0,0,0,187,187,51,51,51,51,51,51,51,51,51,51,51,51,187,187,0,0,0,0,0,0 f�� 0,0,0,0,0,0,0,0,0,0,0,187,187,187,51,51,51,51,51,51,51,51,187,187,187 ��� 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,187,187,187,187,187,187,187 ��� 187,187,187,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,187 E�� 187,187,187,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ��� 0,11,187,187,180,68,68,68,68,68,68,68,68,68,68,75,187,187,176,0,0,0,0 ��� 0,0,0,0,0,0,0,0,0,11,187,180,68,68,68,68,68,68,68,68,68,68,68,68,68 &�� 68,75,187,176,0,0,0,0,0,0,0,0,0,0,0,0,187,68,68,68,68,68,68,68,68,68 p�� 68,68,68,68,68,68,68,68,68,187,0,0,0,0,0,0,0,0,0,0,0,0,187,68,68,68 ��� 68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,187,0,0,0,0,0,0,0,0,0,0 � 0,0,11,187,180,68,68,68,68,68,68,68,68,68,68,68,68,68,68,75,187,176,0 R� 0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,180,68,68,68,68,68,68,68,68,68,68 �� 75,187,187,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,187,187,187 �"� 187,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,187 6,� 187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0 �6� 0,0,0,0,0,0,0,0,0,187,187,187,85,85,85,85,85,85,85,85,85,85,85,85,85 �@� 85,187,187,187,0,0,0,0,0,0,0,0,0,0,0,187,187,85,85,85,85,85,85,85,85 J� 85,85,85,85,85,85,85,85,85,85,187,187,0,0,0,0,0,0,0,0,0,11,181,85,85 bT� 85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,91,176,0,0,0,0 �^� 0,0,0,0,11,181,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85 �h� 85,85,91,176,0,0,0,0,0,0,0,0,0,187,187,85,85,85,85,85,85,85,85,85,85 C r� 85,85,85,85,85,85,85,85,187,187,0,0,0,0,0,0,0,0,0,0,0,187,187,187,85 � |� 85,85,85,85,85,85,85,85,85,85,85,85,85,187,187,187,0,0,0,0,0,0,0,0,0 � �� 0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187 #!�� 187,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,187,187,187,187,187,187 l!�� 187,187,187,187,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,11 �!�� 187,187,182,102,102,102,102,102,102,102,102,102,102,102,102,102,102 "�� 102,102,107,187,187,176,0,0,0,0,0,0,0,11,187,182,102,102,102,102,102 K"�� 102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,107,187 �"�� 176,0,0,0,0,0,0,187,102,102,102,102,102,102,102,102,102,102,102,102 �"�� 102,102,102,102,102,102,102,102,102,102,102,102,187,0,0,0,0,0,0,187 )#�� 102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102 r#�� 102,102,102,102,102,102,102,187,0,0,0,0,0,0,11,187,182,102,102,102 �#�� 102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102 $�� 107,187,176,0,0,0,0,0,0,0,11,187,187,182,102,102,102,102,102,102,102 S$�� 102,102,102,102,102,102,102,102,102,107,187,187,176,0,0,0,0,0,0,0,0,0 �$� 0,11,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187 �$� 187,187,176,0,0,0,0,0,0,0,0,0,0,0,187,187,187,187,187,187,187,187,187 4%� 187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0,0 ~%&� 187,187,187,119,119,119,119,119,119,119,119,119,119,119,119,119,119 �%0� 119,119,119,119,119,119,187,187,187,0,0,0,0,0,187,187,119,119,119,119 &:� 119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119 _&D� 119,119,119,187,187,0,0,0,11,183,119,119,119,119,119,119,119,119,119 �&N� 119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119 �&X� 123,176,0,0,11,183,119,119,119,119,119,119,119,119,119,119,119,119 >'b� 119,119,119,119,119,119,119,119,119,119,119,119,119,119,123,176,0,0,0 �'l� 187,187,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119 �'v� 119,119,119,119,119,119,119,119,119,187,187,0,0,0,0,0,187,187,187,119 (�� 119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119 h(�� 119,119,187,187,187,0,0,0,0,0,0,0,0,187,187,187,187,187,187,187,187 �(�� 187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0 �(�� 0,11,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187 H)�� 187,187,187,187,187,187,187,187,176,0,0,0,0,11,187,187,184,136,136 �)�� 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136 �)�� 136,136,136,139,187,187,176,0,11,187,184,136,136,136,136,136,136,136 '*�� 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136 q*�� 136,136,139,187,176,187,136,136,136,136,136,136,136,136,136,136,136 �*�� 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136 +�� 136,136,187,187,136,136,136,136,136,136,136,136,136,136,136,136,136 O+�� 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136 �+�� 187,11,187,184,136,136,136,136,136,136,136,136,136,136,136,136,136 �+� 136,136,136,136,136,136,136,136,136,136,136,136,136,139,187,176,0,11 -,� 187,187,184,136,136,136,136,136,136,136,136,136,136,136,136,136,136 v,� 136,136,136,136,136,136,136,136,139,187,187,176,0,0,0,0,11,187,187 �, � 187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187 �,*� 187,187,187,187,187,176,0,0,0,-1   