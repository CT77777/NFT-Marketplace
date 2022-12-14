const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("NFT marketplace", function () {
  let owner,
    user1,
    user2,
    nftMarketplace,
    liquidityVault,
    nft1,
    nft2,
    utilityNFT,
    weth,
    usdc,
    usdt;

  async function deployTestContracts() {
    const [owner, user1, user2] = await ethers.getSigners();

    const wethFactory = await ethers.getContractFactory("WETH", owner);
    const weth = await wethFactory.deploy();
    await weth.deployed();

    const usdtFactory = await ethers.getContractFactory("USDT", owner);
    const usdt = await usdtFactory.deploy();
    await usdt.deployed();

    const usdcFactory = await ethers.getContractFactory("USDC", owner);
    const usdc = await usdcFactory.deploy();
    await usdc.deployed();

    const nft1Factory = await ethers.getContractFactory("ERC721test1", owner);
    const nft1 = await nft1Factory.deploy();
    await nft1.deployed();

    const nft2Factory = await ethers.getContractFactory("ERC721test2", owner);
    const nft2 = await nft2Factory.deploy();
    await nft2.deployed();

    const utilityNFTFactory = await ethers.getContractFactory(
      "utilityNFT",
      owner
    );
    const utilityNFT = await utilityNFTFactory.deploy();
    await utilityNFT.deployed();

    const nftMarketplaceFactory = await ethers.getContractFactory(
      "NFTmarketplace",
      owner
    );
    const nftMarketplace = await nftMarketplaceFactory.deploy(
      utilityNFT.address,
      0,
      weth.address,
      usdc.address,
      usdt.address
    );
    await nftMarketplace.deployed();

    const liquidityVaultFactory = await ethers.getContractFactory(
      "liquidityVault",
      owner
    );
    const liquidityVault = await liquidityVaultFactory.deploy(
      nftMarketplace.address,
      weth.address,
      10
    );
    await liquidityVault.deployed();

    await utilityNFT.connect(user1).mint(10);
    await utilityNFT.connect(owner).mint(50);

    await nft1.connect(user1).mint(5);
    await nft2.connect(user2).mint(5);

    await weth.connect(user1).mint(ethers.utils.parseUnits("100", 18));
    await weth.connect(user2).mint(ethers.utils.parseUnits("100", 18));
    await weth.connect(owner).mint(ethers.utils.parseUnits("1000", 18));

    await nft1.connect(user1).setApprovalForAll(nftMarketplace.address, true);
    await nft2.connect(user2).setApprovalForAll(nftMarketplace.address, true);
    await utilityNFT
      .connect(user1)
      .setApprovalForAll(nftMarketplace.address, true);
    await utilityNFT
      .connect(owner)
      .setApprovalForAll(nftMarketplace.address, true);

    await weth
      .connect(user1)
      .approve(nftMarketplace.address, ethers.utils.parseUnits("10000", 18));
    await weth
      .connect(user2)
      .approve(nftMarketplace.address, ethers.utils.parseUnits("10000", 18));
    await weth
      .connect(owner)
      .approve(nftMarketplace.address, ethers.utils.parseUnits("10000", 18));
    await weth
      .connect(owner)
      .approve(liquidityVault.address, ethers.utils.parseUnits("10000", 18));
    await weth
      .connect(user1)
      .approve(liquidityVault.address, ethers.utils.parseUnits("10000", 18));

    await nftMarketplace
      .connect(owner)
      .approve(liquidityVault.address, ethers.utils.parseUnits("10000", 18));
    await nftMarketplace
      .connect(user1)
      .approve(liquidityVault.address, ethers.utils.parseUnits("10000", 18));

    return {
      owner,
      user1,
      user2,
      nftMarketplace,
      liquidityVault,
      nft1,
      nft2,
      utilityNFT,
      weth,
      usdc,
      usdt,
    };
  }

  beforeEach(async function () {
    let fixture = await loadFixture(deployTestContracts);
    owner = fixture.owner;
    user1 = fixture.user1;
    user2 = fixture.user2;
    nftMarketplace = fixture.nftMarketplace;
    liquidityVault = fixture.liquidityVault;
    nft1 = fixture.nft1;
    nft2 = fixture.nft2;
    utilityNFT = fixture.utilityNFT;
    weth = fixture.weth;
    usdc = fixture.usdc;
    usdt = fixture.usdt;
  });

  describe("Exchange", function () {
    it("user1 can get one nft2, user2 can get one nft1", async function () {
      await nftMarketplace
        .connect(user1)
        .applyExchangeTransaction(
          user2.address,
          nft1.address,
          0,
          nft2.address,
          3,
          weth.address,
          0,
          0
        );
      await nftMarketplace.connect(user2).confirmExchangeTransaction(0);
      expect(await nft2.balanceOf(user1.address)).to.equal(1);
      expect(await nft2.ownerOf(3)).to.equal(user1.address);
      expect(await nft1.balanceOf(user2.address)).to.equal(1);
      expect(await nft2.ownerOf(0)).to.equal(user2.address);
    });
  });

  describe("Sell", function () {
    it("user1 can get WETH, user2 can get the nft1", async function () {
      await nftMarketplace
        .connect(user1)
        .applySellTransaction(
          user2.address,
          nft1.address,
          0,
          weth.address,
          ethers.utils.parseUnits("5", 18)
        );
      await nftMarketplace.connect(user2).confirmSellTransaction(0);

      expect(await weth.balanceOf(user1.address)).to.equal(
        ethers.utils.parseUnits("105", 18)
      );
      expect(await nft1.balanceOf(user1.address)).to.equal(4);
      expect(await weth.balanceOf(user2.address)).to.equal(
        ethers.utils.parseUnits("95", 18)
      );
      expect(await nft1.balanceOf(user2.address)).to.equal(1);
    });
  });

  describe("Bid", function () {
    it("user1 can get any one of nft2, user2 can get bidding WETH", async function () {
      await nftMarketplace
        .connect(user1)
        .applyBidTransaction(
          nft2.address,
          weth.address,
          ethers.utils.parseUnits("10", 18)
        );
      await nftMarketplace.connect(user2).confirmBidTransaction(0, 2);

      expect(await weth.balanceOf(user1.address)).to.equal(
        ethers.utils.parseUnits("90", 18)
      );
      expect(await nft2.balanceOf(user1.address)).to.equal(1);
      expect(await weth.balanceOf(user2.address)).to.equal(
        ethers.utils.parseUnits("110", 18)
      );
      expect(await nft2.balanceOf(user2.address)).to.equal(4);
    });
  });

  describe("Fragment/Recombie", function () {
    it("Fragment: user1 can get 100 FMMC token when stake one utilityNFT", async function () {
      await nftMarketplace.connect(user1).fragment([7]);
      expect(await utilityNFT.balanceOf(user1.address)).to.equal(9);
      expect(await nftMarketplace.balanceOf(user1.address)).to.equal(
        ethers.utils.parseUnits("100", 18)
      );
    });

    it("Recombie: user1 can get 1 utilityNFT when burn 100 FMMC token", async function () {
      await nftMarketplace.connect(user1).fragment([7]);
      await nftMarketplace.connect(user1).recombine([7]);
      expect(await nftMarketplace.balanceOf(user1.address)).to.equal(
        ethers.utils.parseUnits("0", 18)
      );
      expect(await utilityNFT.balanceOf(user1.address)).to.equal(10);
    });
  });

  describe("Get WETH liquidity from liquidityVaule with FMMC token", function () {
    it("Founder add liquidity", async function () {
      await nftMarketplace
        .connect(owner)
        .fragment([10, 11, 12, 13, 14, 15, 16, 17, 18, 19]);
      await liquidityVault
        .connect(owner)
        .addLiquidity(ethers.utils.parseUnits("1000", 18));
      expect(await weth.balanceOf(liquidityVault.address)).to.equal(
        ethers.utils.parseUnits("50", 18)
      );
    });

    it("user1 get WETH by swap FMMC token", async function () {
      await nftMarketplace
        .connect(owner)
        .fragment([10, 11, 12, 13, 14, 15, 16, 17, 18, 19]);
      await liquidityVault
        .connect(owner)
        .addLiquidity(ethers.utils.parseUnits("1000", 18));

      await nftMarketplace.connect(user1).fragment([7]);
      await liquidityVault
        .connect(user1)
        .swap(
          nftMarketplace.address,
          ethers.utils.parseUnits("50", 18),
          weth.address
        );
      expect(await weth.balanceOf(user1.address)).to.gt(
        ethers.utils.parseUnits("100", 18)
      );
    });
  });
});
