Comparative Evaluation of Hand-Crafted and Learned Local Features
=================================================================

This repository contains the instructions and the code for evaluating feature
descriptors on our image-based reconstruction benchmark. The details of our
local feature benchmark can be found in our paper:

    "Comparative Evaluation of Hand-Crafted and Learned Local Features".
    J.L. Schönberger, H. Hardmeier, T. Sattler and M. Pollefeys. CVPR 2017.

  [Paper](https://demuc.de/papers/schoenberger2017comparative.pdf),
  [Supplementary](https://demuc.de/papers/schoenberger2017comparative_supp.pdf),
  [Bibtex](https://demuc.de/papers/schoenberger2017comparative.bib)

You might also be interested in the [*HPatches*](https://hpatches.github.io/)
benchmark by Balntas and Lenc et al. presented at CVPR 2017.


Benchmark Results
-----------------

This list is updated with the latest benchmark results. Note that the results
differ from the original paper, since they were updated with the latest COLMAP
version. Numbers of some of the features are still missing for the latest COLMAP
version and will be added shortly after recomputing them. If you want to submit
your own results, please open a new issue or pull request in this repository.
Note that the below table extends to the right and alternatively can be viewed
in a code or text editor.

**Metrics:**

| Dataset           | Method   | # Images | # Reg. Images | # Sparse Points | # Observations | Track Length | Obs. Per Image | Reproj. Error [px] | # Dense Points | Dense Error [2cm] | Dense Error [10cm] | Mean Pose Error [m] | Median Pose Error [m] | # Inlier Pairs | # Inlier Matches |
|:------------------|:---------|---------:|--------------:|----------------:|---------------:|-------------:|---------------:|-------------------:|---------------:|------------------:|-------------------:|--------------------:|----------------------:|---------------:|-----------------:|
| Fountain          | SIFT     |       11 |            11 |           14722 |          70631 |      4.79765 |        6421.00 |           0.392893 |         292609 |                   |                    |                     |                       |             55 |           127734 |
|                   | SIFT-PCA |          |            11 |           14281 |          67776 |      4.74588 |        6161.45 |           0.379411 |         295870 |                   |                    |                     |                       |             55 |           117257 |
|                   | DSP-SIFT |          |            11 |           14867 |          71153 |      4.78596 |        6468.45 |           0.414944 |         293789 |                   |                    |                     |                       |             55 |           130820 |
|                   | ConvOpt  |          |            11 |           14717 |          70614 |      4.79812 |        6419.45 |           0.393435 |         296522 |                   |                    |                     |                       |             55 |           127540 |
| ***               | TFeat    |          |            11 |           13696 |          64110 |      4.68093 |        5828.18 |           0.352238 |        2969328 |            0.7677 |             0.8969 |            0.002412 |              0.002412 |             54 |           103260 |
| ***               | DeepDesc |          |            11 |           13519 |          61478 |      4.54753 |        5588.91 |           0.353349 |        2972715 |            0.7677 |             0.8969 |            0.002413 |              0.002413 |             55 |            93708 |
|                   | LIFT     |          |            11 |            6003 |          28296 |      4.71364 |        2572.36 |           0.580594 |         304258 |                   |                    |                     |                       |             55 |            52293 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| Herzjesu          | SIFT     |        8 |             8 |            7502 |          31670 |      4.22154 |        3958.75 |           0.431632 |         241347 |                   |                    |                     |                       |             28 |            48965 |
|                   | SIFT-PCA |          |             8 |            7161 |          29735 |      4.15235 |        3716.87 |           0.409061 |         245291 |                   |                    |                     |                       |             28 |            44443 |
|                   | DSP-SIFT |          |             8 |            7769 |          32809 |      4.22306 |        4101.12 |           0.459535 |         238122 |                   |                    |                     |                       |             28 |            51893 |
|                   | ConvOpt  |          |             8 |            4957 |          20227 |      4.08049 |        2528.37 |           0.387640 |         242262 |                   |                    |                     |                       |             26 |            27830 |
| ***               | TFeat    |          |             8 |            6606 |          27021 |      4.09037 |        3377.62 |           0.381651 |        2377038 |            0.5734 |             0.7304 |            0.003533 |              0.003533 |             28 |            38573 |
| ***               | DeepDesc |          |             8 |            6418 |          25139 |      3.91695 |        3142.38 |           0.379522 |        2380244 |            0.5734 |             0.7307 |            0.003533 |              0.003533 |             28 |            34591 |
|                   | LIFT     |          |             8 |            3742 |          14890 |      3.97915 |        1861.25 |           0.620034 |         241173 |                   |                    |                     |                       |             28 |            22683 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| South-Building    | SIFT     |      128 |           128 |          108124 |         653975 |      6.04838 |        5109.18 |           0.545747 |        2141964 |                   |                    |                     |                       |           3822 |          2036024 |
|                   | SIFT-PCA |          |           128 |          105612 |         632145 |      5.98554 |        4938.63 |           0.531500 |        2090915 |                   |                    |                     |                       |           3979 |          1927873 |
|                   | DSP-SIFT |          |           128 |          112719 |         666808 |      5.91566 |        5209.43 |           0.580537 |        2141873 |                   |                    |                     |                       |           3958 |          2076833 |
|                   | ConvOpt  |          |           128 |           62306 |         397579 |      6.38107 |        3106.08 |           0.487924 |        2117221 |                   |                    |                     |                       |           1901 |           984762 |
| ***               | TFeat    |          |           128 |           94589 |         566687 |      5.99105 |        4427.24 |           0.486924 |        1960970 |                   |                    |                     |                       |           3156 |          1567873 |
| ***               | DeepDesc |          |           128 |          101154 |         558997 |      5.52620 |        4367.16 |           0.483270 |        2002399 |                   |                    |                     |                       |           6034 |          1463340 |
|                   | LIFT     |          |           128 |           42601 |         233110 |      5.47193 |        1821.17 |           0.730874 |        2154755 |                   |                    |                     |                       |           2830 |           711142 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| Madrid Metropolis | SIFT     |     1344 |           500 |          116088 |         733745 |      6.32053 |        1467.49 |           0.605330 |        1822434 |                   |                    |                     |                       |         227092 |          6969437 |
|                   | SIFT-PCA |          |           469 |          111090 |         645437 |      5.81003 |        1376.19 |           0.586054 |        1571584 |                   |                    |                     |                       |         644573 |         13970478 |
|                   | DSP-SIFT |          |           467 |           99514 |         649704 |      6.52877 |        1391.22 |           0.660135 |        1643614 |                   |                    |                     |                       |         135215 |          4586807 |
|                   | ConvOpt  |          |           348 |           40749 |         213176 |      5.23144 |         612.57 |           0.534638 |        1251705 |                   |                    |                     |                       |         665669 |         12531539 |
| ***               | TFeat    |          |           439 |           90274 |         512470 |      5.67683 |        1167.36 |           0.538515 |         522327 |                   |                    |                     |                       |          18450 |          2135644 |
| ***               | DeepDesc |          |           377 |           68110 |         348061 |      5.11028 |        923.239 |           0.526658 |         516535 |                   |                    |                     |                       |          19782 |          1570887 |
|                   | LIFT     |          |           416 |           44056 |         303055 |      6.87885 |        728.497 |           0.768777 |        1577304 |                   |                    |                     |                       |          82562 |          2531640 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| Gendarmenmarkt    | SIFT     |     1463 |          1035 |          338972 |        1872308 |      5.52348 |        1809.00 |           0.699118 |        4225031 |                   |                    |                     |                       |         321854 |         12625310 |
|                   | SIFT-PCA |          |           975 |          349217 |        1690464 |      4.84072 |        1733.80 |           0.701904 |        3649260 |                   |                    |                     |                       |         822997 |         20321433 |
|                   | DSP-SIFT |          |           979 |          293209 |        1577921 |      5.38155 |        1611.76 |           0.749714 |        2600189 |                   |                    |                     |                       |         265575 |          9315075 |
|                   | ConvOpt  |          |           772 |          178859 |         694211 |      3.88133 |         899.23 |           0.723822 |        2955105 |                   |                    |                     |                       |         811724 |         15583270 |
| ***               | TFeat    |          |           953 |          297266 |        1445049 |      4.86113 |        1516.32 |           0.660397 |        1181279 |                   |                    |                     |                       |          39115 |          4685369 |
| ***               | DeepDesc |          |           809 |          244925 |         949216 |      3.87554 |        1173.32 |           0.681721 |         921231 |                   |                    |                     |                       |          31134 |          2849341 |
|                   | LIFT     |          |           959 |          142982 |         819940 |      5.73456 |         854.99 |           0.841945 |        3939957 |                   |                    |                     |                       |         125084 |          5012767 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| Tower of London   | SIFT     |     1576 |           804 |          239951 |        1863301 |      7.76534 |        2317.53 |           0.615406 |        3050252 |                   |                    |                     |                       |         165097 |         11249925 |
|                   | SIFT-PCA |          |           693 |          220381 |        1491686 |      6.76866 |        2152.50 |           0.602057 |        2518677 |                   |                    |                     |                       |         558173 |         14605601 |
|                   | DSP-SIFT |          |           799 |          267906 |        1940752 |      7.24415 |        2428.97 |           0.655440 |        2946702 |                   |                    |                     |                       |         260963 |         12750104 |
|                   | ConvOpt  |          |           537 |          143397 |         788855 |      5.50119 |        1469.00 |           0.580207 |        2448215 |                   |                    |                     |                       |         742322 |         14648025 |
| ***               | TFeat    |          |           714 |          206142 |        1424696 |      6.91124 |        1995.37 |           0.572171 |        1182746 |                   |                    |                     |                       |          28388 |          5333355 |
| ***               | DeepDesc |          |           551 |          196990 |         964750 |      4.89746 |        1750.91 |           0.545235 |         653579 |                   |                    |                     |                       |          25658 |          2745700 |
|                   | LIFT     |          |           713 |           96848 |         739340 |      7.63402 |        1036.94 |           0.728200 |        2879455 |                   |                    |                     |                       |          60841 |          3628677 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| Alamo             | SIFT     |     2915 |           963 |          198433 |        2437084 |     12.28164 |        2530.72 |           0.647271 |        3737516 |                   |                    |                     |                       |          64068 |         21263831 |
|                   | SIFT-PCA |          |           921 |          197723 |        2279339 |     11.52791 |        2474.85 |           0.626812 |        3256364 |                   |                    |                     |                       |         143747 |         20145150 |
|                   | DSP-SIFT |          |           961 |          223192 |        2564659 |     11.49082 |        2668.73 |           0.712005 |        3815012 |                   |                    |                     |                       |          79973 |         23375984 |
|                   | ConvOpt  |          |           684 |          110261 |        1167754 |     10.59081 |        1707.24 |           0.537849 |        2546861 |                   |                    |                     |                       |         168383 |          8065721 |
| ***               | TFeat    |          |           683 |          127642 |        1443116 |     11.30600 |        2112.91 |           0.521289 |         648970 |                   |                    |                     |                       |          16764 |          6356806 |
| ***               | DeepDesc |          |           665 |          152537 |        1207394 |      7.91542 |        1815.63 |           0.479996 |         607091 |                   |                    |                     |                       |          16691 |          4196845 |
|                   | LIFT     |          |           796 |           78892 |        1011117 |    12.816471 |        1270.24 |           0.768177 |        2900266 |                   |                    |                     |                       |          40219 |          8151208 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| Roman Forum       | SIFT     |     2364 |          1679 |          433152 |        3603662 |      8.31962 |        2146.31 |           0.708420 |        9630170 |                   |                    |                     |                       |          76547 |         16424472 |
|                   | SIFT-PCA |          |          1663 |          434317 |        3267075 |      7.52232 |        1964.56 |           0.674920 |        9379870 |                   |                    |                     |                       |         151694 |         15134227 |
|                   | DSP-SIFT |          |          1644 |          464792 |        3653745 |      7.86103 |        2222.47 |           0.749306 |        9429283 |                   |                    |                     |                       |         100827 |         16469792 |
|                   | ConvOpt  |          |          1282 |          182922 |        1263324 |      6.90635 |         985.43 |           0.627904 |        7404163 |                   |                    |                     |                       |         158940 |          6151296 |
| ***               | TFeat    |          |          1450 |          271902 |        1963303 |      7.22063 |        1354.00 |           0.608724 |        3477858 |                   |                    |                     |                       |          19828 |          5584122 |
| ***               | DeepDesc |          |          1173 |          174532 |        1275633 |      7.30887 |        1087.49 |           0.602312 |        2434123 |                   |                    |                     |                       |           9831 |          1834623 |
|                   | LIFT     |          |          1503 |          174430 |        1420800 |      8.14538 |         945.30 |           0.814467 |        8584480 |                   |                    |                     |                       |          49413 |          5775222 |
|                   |          |          |               |                 |                |              |                |                    |                |                   |                    |                     |                       |                |                  |
| Cornell           | SIFT     |     6514 |          6073 |         1847141 |       12865681 |      6.96518 |        2118.50 |           0.660522 |       35232209 |                   |                    |                     |                       |         227478 |         61428156 |
|                   | SIFT-PCA |          |          6010 |         1856258 |       12307131 |      6.63007 |        2047.77 |           0.643796 |       35263104 |                   |                    |                     |                       |         417668 |         59874790 |
|                   | DSP-SIFT |          |          6069 |         2071407 |       13671952 |      6.60032 |        2252.75 |           0.708143 |       35449395 |                   |                    |                     |                       |         283503 |         64364585 |
|                   | ConvOpt  |          |          5009 |          938316 |        6082683 |      6.48255 |        1214.35 |           0.570824 |       30619302 |                   |                    |                     |                       |         353461 |         25017605 |
| ***               | TFeat    |          |          5428 |         1499117 |        9830787 |      6.55772 |        1811.13 |           0.587575 |       15605086 |                   |                    |            2.125709 |              0.593038 |          89927 |         40640025 |
| ***               | DeepDesc |          |          3489 |         1225780 |        6977970 |      5.69268 |        1999.99 |           0.552574 |       10159770 |                   |                    |            3.831561 |              0.695395 |          73973 |         28845684 |
|                   | LIFT     |          |          5518 |          739059 |        4602081 |      6.22694 |         834.01 |           0.730208 |       33372173 |                   |                    |                     |                       |         143408 |         19144270 |

**Runtime:**

| Method   | Runtime  | Hardware                                               |
|:---------|---------:|:-------------------------------------------------------|
| SIFT     |     9.3s | (Intel E5-2697 2.60GHz CPU - single-threaded)          |
| SIFT-PCA |    10.5s | (Intel E5-2697 2.60GHz CPU - single-threaded)          |
| DSP-SIFT |    23.7s | (Intel E5-2697 2.60GHz CPU - single-threaded)          |
| ConvOpt  |    49.9s | (Intel E5-2697 2.60GHz CPU, NVIDIA Titan X GPU)        |
| DeepDesc |    24.3s | (Intel E5-2697 2.60GHz CPU, NVIDIA Titan X GPU)        |
| TFeat    |    11.8s | (Intel E5-2697 2.60GHz CPU, NVIDIA Titan X GPU)        |
| LIFT     |   212.3s | (Intel E5-2697 2.60GHz CPU, NVIDIA Titan X GPU)        |

**References:**

- *SIFT*: D.G. Lowe: Object Recognition from Local Scale-Invariant Features.
  ICCV, 1999. R. Arandjelovic and A. Zisserman. Three things everyone should
  know to improve object retrieval. CVPR, 2012.
- *SIFT-PCA*: A. Bursuc, G. Tolias, and H. Jegou. Kernel local descriptors
  with implicit rotation matching. ACM Multimedia, 2015.
- *DSP-SIFT*: J.Dong and S.Soatto.
  Domain-size pooling in local descriptors: DSP-SIFT. CVPR, 2015.
- *ConvOpt*: K. Simonyan, A. Vedaldi, and A. Zisserman. Learning local
  feature descriptors using convex optimisation. PAMI, 2014.
- *DeepDesc*: E. Simo-Serra, E. Trulls, L. Ferraz, I. Kokkinos, P. Fua, and
  F. Moreno-Noguer. Discriminative learning of deep convolutional feature point
  descriptors. ICCV, 2015.
- *TFeat*: V.Balntas, E.Riba, D.Ponsa, and K.Mikolajczyk.
  Learning local feature descriptors with triplets and shallow convolutional
  neural networks. BMVC, 2016.
- *LIFT*: M. Kwang, E. Trulls, V. Lepetit, and P. Fua.
  LIFT: Learned Invariant Feature Transform. ECCV, 2016.
