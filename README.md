# MIDERO
Demonstration of robotic with Ada. Midero (Mine Detector Robot) is a platform with capabilities of detecting burried mines.

## Why Ada ?
**Ada** is an easy-to-learn multi-paradigm programming language. It is used in the development of real-time embedded systems such as airplane, cars and robotic platform also used in web applications. 



## Prerequesite (tested on linux ubuntu 22.04 )

**Alire**: <https://github.com/alire-project/alire/releases>

1. Download and unzip the latest linux zip
2. Add *where_you_unzipped/alr* to PATH.
3. Install [wolfbiters index](<https://github.com/wolfbiters/>) locally:

    alr index --add git+https://github.com/wolfbiters/alire-index.git#stable-1.2.1 --name testindex
   
4. Verify Alire is found on your path by running this command on your terminal:

    which alr
    
5. When you are done, you can delete it:

    alr index --del testindex

## OpenOCD

Here is a [very good tutorial](<https://youtu.be/-p26X8lTAvo>) on how to install openocd on ubuntu.


**STM32f429 Discovery board**\
\
![stm32f429disco](/stm32f429disco.jpeg)
* Plug it to your computer using the [USB MINI B cable](<https://fr.aliexpress.com/item/1005001942868270.html?algo_pvid=ca3f3071-36ed-4210-9a35-d2635ae72b56&algo_exp_id=ca3f3071-36ed-4210-9a35-d2635ae72b56-0&pdp_ext_f=%7B%22sku_id%22%3A%2212000018176126358%22%7D&pdp_npi=3%40dis%21XOF%211301.0%211042.0%21%21%21%21%21%402102172f16777957964894627d06fd%2112000018176126358%21sea%21SN%210&curPageLogUid=OkJbd81354FL>)


## Download 
if you don't have git yet, you can downloaded it [here](https://git-scm.com/downloads).

Then create a new folder or move in the directory of your choice and clone this repository by running:

    git clone https://github.com/bullyDD/MIDERO.git

## Tools
For my programming journey, I used Adacore IDE named gnatstudio which I think is a nice tools if you program with Ada. It is available on <https://adacore.com/download>.

## Build
Inside midero repo, issue this command to install all dependencies, build gpr file and open gnatstudio:

    ./make.sh


## Build and upload your program in your board
On your terminal, run:

    ./run.sh


