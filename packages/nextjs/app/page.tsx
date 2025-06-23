"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { Address } from "~~/components/scaffold-eth";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";
import { parseEther } from "viem";
import { useState } from "react";
import { abi } from "./YourContract.json";
import { useReadContract } from 'wagmi'

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();

  const { data: greeting } = useScaffoldReadContract({
    contractName: "YourContract",
    functionName: "greeting",
  });

  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract("YourContract");



  const [valor , setValor] = useState<string>("");

    <>
     <p className="flew-full text-3x1 text-center">{greeting}</p>
     <br />
     <br />
     <input
      type="text"
      className="input input-bordered w-full max-w-xs"
      placeholder="Set greeting"
      value={valor}
      onChange={e => setValor(e.target.value)}
    />
     <button
  className="btn btn-primary"
  onClick={async () => {
    try {
      await writeYourContractAsync({
        functionName: "setGreeting",
        args: [valor],
        value: parseEther("0.1"),
      });
    } catch (e) {
      console.error("Error setting greeting:", e);
    }
  }}
>
  Set Greeting
</button>
    </>

};

export default Home;
