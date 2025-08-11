-- module by Shirrozy on the roblox dev forums <3

local Sha256 = {}

local bit32 = bit32

-- Bitwise right rotation 
local function ROTR(n, x)
	return bit32.bor(bit32.rshift(x, n), bit32.lshift(x, 32 - n))
end

-- Super duper logical functions
local function Sigma0(x) return bit32.bxor(ROTR(2, x), bit32.bxor(ROTR(13, x), ROTR(22, x))) end
local function Sigma1(x) return bit32.bxor(ROTR(6, x), bit32.bxor(ROTR(11, x), ROTR(25, x))) end
local function sigma0(x) return bit32.bxor(ROTR(7, x), bit32.bxor(ROTR(18, x), bit32.rshift(x, 3))) end
local function sigma1(x) return bit32.bxor(ROTR(17, x), bit32.bxor(ROTR(19, x), bit32.rshift(x, 10))) end
local function Ch(x, y, z) return bit32.bxor(bit32.band(x, y), bit32.band(bit32.bnot(x), z)) end
local function Maj(x, y, z) return bit32.bxor(bit32.band(x, y), bit32.bxor(bit32.band(x, z), bit32.band(y, z))) end

-- UTF-8 Encoding <3
local function utf8Encode(str)
	local bytes = {}
	for i = 1, #str do
		table.insert(bytes, string.byte(str, i))
	end
	return bytes
end

function Sha256.hash(message)
	local K = {
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
		0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
		0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
		0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
		0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
		0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
		0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
		0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
		0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
		0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
		0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
		0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
	}

	local H = {
		0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
		0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
	}

	-- Preprocessing
	local bytes = utf8Encode(message)
	local bitLen = #bytes * 8

	table.insert(bytes, 0x80)
	while (#bytes + 8) % 64 ~= 0 do
		table.insert(bytes, 0x00)
	end

	for i = 8, 1, -1 do
		table.insert(bytes, bit32.band(bit32.rshift(bitLen, (i - 1) * 8), 0xff))
	end

	-- Process each 512-bit chunk
	for i = 1, #bytes, 64 do
		local w = {}

		for j = 0, 15 do
			local k = i + j * 4
			local a = bytes[k] or 0
			local b = bytes[k + 1] or 0
			local c = bytes[k + 2] or 0
			local d = bytes[k + 3] or 0
			w[j + 1] = bit32.bor(bit32.lshift(a, 24), bit32.lshift(b, 16), bit32.lshift(c, 8), d)
		end

		for j = 17, 64 do
			local s1 = sigma1(w[j - 2])
			local s0 = sigma0(w[j - 15])
			w[j] = bit32.band(w[j - 16] + s0 + w[j - 7] + s1, 0xffffffff)
		end

		local a, b, c, d, e, f, g, h = table.unpack(H)

		for j = 1, 64 do
			local T1 = bit32.band(h + Sigma1(e) + Ch(e, f, g) + K[j] + w[j], 0xffffffff)
			local T2 = bit32.band(Sigma0(a) + Maj(a, b, c), 0xffffffff)

			h = g
			g = f
			f = e
			e = bit32.band(d + T1, 0xffffffff)
			d = c
			c = b
			b = a
			a = bit32.band(T1 + T2, 0xffffffff)
		end

		H[1] = bit32.band(H[1] + a, 0xffffffff)
		H[2] = bit32.band(H[2] + b, 0xffffffff)
		H[3] = bit32.band(H[3] + c, 0xffffffff)
		H[4] = bit32.band(H[4] + d, 0xffffffff)
		H[5] = bit32.band(H[5] + e, 0xffffffff)
		H[6] = bit32.band(H[6] + f, 0xffffffff)
		H[7] = bit32.band(H[7] + g, 0xffffffff)
		H[8] = bit32.band(H[8] + h, 0xffffffff)
	end

	local hash = ""
	for _, v in ipairs(H) do
		hash = hash .. string.format("%08x", v)
	end

	return hash
end

return Sha256
