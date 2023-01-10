# ExNar

[![Hex.pm](https://img.shields.io/hexpm/v/ex_nar.svg)](https://hex.pm/packages/ex_nar) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/ex_nar/)

---

An Elixir Library to create + unpack Nix Archives. Only directly serializes + deserializes, with no intermediate state that can be inspected (PRs welcome :)).

## Usage

``` elixir
# Deserialize 
ExNar.deserialize! ("/path/to/.nar", "")
#=> :ok
# Serialize
ExNar.serialize!("/path/to/serialize")
#=> <<13,0,0,0,...>>

# Serialize byte stream
ExNar.serialize!("hello world", :bytestream)
#=> <<13,0,0,0,...>>
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_nar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_nar, "~> 0.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_nar>.


## Sources

Thanks to Eelco Dolstra, for the specification [The Purely Functional Software
Deployment Model, PG 93, Figure
5.2](https://edolstra.github.io/pubs/phd-thesis.pdf)
